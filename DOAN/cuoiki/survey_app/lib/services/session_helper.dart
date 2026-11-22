import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';

import '../models/member.dart';

class SessionHelper {
  static const _storage = FlutterSecureStorage();
  static Future<void> save(String token, Map<String, dynamic> member) async {
    await _storage.write(key: 'member', value: jsonEncode(member));
    await _storage.write(key: 'token', value: token);
  }

  // Hồ sơ cục bộ chỉ để mở lại app/nháp; quyền API luôn được kiểm tra trên server.
  static Future<Member?> restore() async {
    try {
      if (await token == null) return null;
      final json = await _storage.read(key: 'member');
      return json == null
          ? null
          : Member.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> get token => _storage.read(key: 'token');
  static Future<void> clear() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'member');
  }
}
