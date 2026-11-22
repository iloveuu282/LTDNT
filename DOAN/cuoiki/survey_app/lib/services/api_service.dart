import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_helper.dart';

class ApiService {
  static const defaultUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5080',
  );
  static String _baseUrl = defaultUrl;
  static String get baseUrl => _baseUrl;
  static const _storage = FlutterSecureStorage();
  static const connectionError =
      'Không kết nối được máy chủ. Kiểm tra Wi-Fi và mục Kết nối máy chủ. Nháp đã lưu vẫn dùng được trên điện thoại.';

  static String normalizeUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.port < 1 ||
        uri.port > 65535) {
      throw const FormatException(
        'Nhập địa chỉ gốc, ví dụ http://192.168.1.10:5080, không thêm /api.',
      );
    }
    return uri.replace(path: '').toString();
  }

  static Future<void> initialize() async {
    final saved = await _storage.read(key: 'server_url');
    _baseUrl = normalizeUrl(saved ?? defaultUrl);
  }

  static Future<void> saveServer(String value) async {
    final url = normalizeUrl(value);
    await _storage.write(key: 'server_url', value: url);
    _baseUrl = url;
  }

  static Future<void> checkServer(String value) async {
    try {
      final url = normalizeUrl(value);
      final response = await http
          .get(Uri.parse('$url/api/health'))
          .timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);
      if (response.statusCode != 200 ||
          data is! Map ||
          data['status'] != 'ok') {
        throw Exception('Địa chỉ này chưa trả về máy chủ khảo sát hợp lệ.');
      }
    } on TimeoutException {
      throw Exception(
        'Máy chủ phản hồi quá lâu. Kiểm tra địa chỉ và mạng Wi-Fi.',
      );
    } on http.ClientException {
      throw Exception(connectionError);
    } on FormatException {
      throw Exception(
        'Địa chỉ không hợp lệ hoặc máy chủ không trả về dữ liệu khảo sát.',
      );
    }
  }

  static Future<void> upload(http.MultipartRequest request) async {
    try {
      decode(
        await http.Response.fromStream(
          await request.send().timeout(const Duration(seconds: 30)),
        ).timeout(const Duration(seconds: 30)),
      );
    } on TimeoutException {
      throw Exception(
        'Máy chủ phản hồi quá lâu. Vui lòng tải lại danh sách trước khi gửi lại.',
      );
    } on http.ClientException {
      throw Exception(connectionError);
    }
  }

  static Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final request = http.Request(method, Uri.parse('$baseUrl/api/$path'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await SessionHelper.token}',
      });
      if (data != null) request.body = jsonEncode(data);
      return decode(
        await http.Response.fromStream(
          await request.send().timeout(const Duration(seconds: 20)),
        ).timeout(const Duration(seconds: 20)),
      );
    } on TimeoutException {
      throw Exception('Máy chủ phản hồi quá lâu. Vui lòng thử lại.');
    } on http.ClientException {
      throw Exception(connectionError);
    }
  }

  static dynamic decode(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }
    if (response.statusCode >= 400) {
      if (response.statusCode == 401) {
        throw Exception(
          'Phiên đã hết hạn. Vui lòng đăng xuất và đăng nhập lại.',
        );
      }
      if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện chức năng này.');
      }
      throw Exception(
        body is Map
            ? body['message'] ?? 'Dữ liệu không hợp lệ hoặc không còn tồn tại.'
            : 'Không thể xử lý yêu cầu.',
      );
    }
    return body;
  }

  static String imageUrl(String path) => '$baseUrl$path';
}
