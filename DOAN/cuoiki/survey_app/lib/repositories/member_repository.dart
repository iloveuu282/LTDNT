import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/member.dart';
import '../services/session_helper.dart';
import '../services/api_service.dart';

class MemberRepository {
  static Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) => ApiService.request(method, path, data);

  static Future<void> changePassword(String current, String next) async {
    await request('POST', 'auth/change-password', {
      'currentPassword': current,
      'newPassword': next,
    });
  }

  static Future<bool> logout() async {
    var revoked = true;
    try {
      await request('POST', 'auth/logout');
    } catch (error) {
      revoked = error.toString().contains('Phiên đã hết hạn');
    }
    await SessionHelper.clear();
    return revoked;
  }

  static Future<List<Member>> getMembers() async {
    final data = await request('GET', 'members') as List;
    return data
        .map((item) => Member.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<List<String>> getRoles() async =>
      (await request('GET', 'members/roles') as List).cast<String>();
  static Future<void> updateMember(
    Member member,
    String name,
    String role,
    bool active,
  ) async {
    await request('PUT', 'members/${member.memberId}', {
      'fullName': name,
      'roleName': role,
      'isActive': active,
    });
  }

  static Future<void> deleteMember(int id) async {
    await request('DELETE', 'members/$id');
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> data,
  ) async {
    final response = await http
        .post(
          Uri.parse('${ApiService.baseUrl}/api/auth/$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(
        body['message'] ??
            'Dữ liệu không hợp lệ. Kiểm tra email và mật khẩu (8–64 ký tự).',
      );
    }
    return body;
  }

  static Future<Member> login(String email, String password) async {
    final data = await _post('login', {
      'email': email.trim(),
      'password': password,
    });
    final member = Member.fromMap(data['member'] as Map<String, dynamic>);
    await SessionHelper.save(
      data['token'] as String,
      data['member'] as Map<String, dynamic>,
    );
    return member;
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    await _post('register', {
      'fullName': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }
}
