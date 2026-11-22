// Bài kiểm tra SQLite chạy độc lập trên Android, không cần kết nối debugger.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survey_app/local/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final root = await getDatabasesPath();
  final path = join(root, 'business_survey_device_check.db');
  final checks = <String>[];
  String? error;
  void check(bool condition, String name) {
    if (!condition) throw StateError(name);
    checks.add(name);
  }

  try {
    await LocalDatabase.open(databasePath: path);
    await LocalDatabase.clearDrafts(-1000);
    await LocalDatabase.clearDrafts(-1001);
    final payload = jsonEncode({
      'answers': {
        '1': 'Góp ý trên Android',
        '2': 'Có',
        '3': ['Giá', 'Chất lượng'],
        '4': 5,
      },
      'submissionId': 'unchanged-id',
    });
    await LocalDatabase.saveDraft(-1000, -2000, -3000, payload);
    await LocalDatabase.saveDraft(
      -1001,
      -2000,
      -3000,
      '{"answers":{"1":"Other member"}}',
    );
    check(
      (await LocalDatabase.drafts(-1000)).length == 1,
      'Save actual SQLite draft on Android',
    );
    await LocalDatabase.close();
    await LocalDatabase.open(databasePath: path);
    var row = await LocalDatabase.draft(-1000, -2000);
    var data = jsonDecode(row!['payload_json'] as String) as Map;
    check(
      data['submissionId'] == 'unchanged-id',
      'Preserve submission id after close and reopen',
    );
    check(
      jsonEncode(data['answers']) ==
          jsonEncode((jsonDecode(payload) as Map)['answers']),
      'Preserve text, single, multiple and rating answers',
    );
    await LocalDatabase.saveDraft(-1000, -2000, -3000, payload);
    check(
      (await LocalDatabase.drafts(-1000)).length == 1,
      'Update same draft without duplicate',
    );
    await LocalDatabase.clearDrafts(-1000);
    check(
      (await LocalDatabase.drafts(-1000)).isEmpty &&
          (await LocalDatabase.drafts(-1001)).length == 1,
      'Clear only selected member data',
    );
    await LocalDatabase.deleteDraft(-1001, -2000);
    check((await LocalDatabase.drafts(-1001)).isEmpty, 'Delete saved draft');
  } catch (e) {
    error = e.toString();
  } finally {
    await LocalDatabase.close();
    await deleteDatabase(path);
  }
  final report = {
    'passed': error == null,
    'count': checks.length,
    'checks': checks,
    'error': error,
  };
  await File(join(root, 'device-sqlite-check-result.json'))
      .writeAsString(jsonEncode(report));
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra SQLite Android')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error == null
                ? 'ĐẠT ${checks.length} kiểm tra. Database tạm đã được xóa.'
                : 'LỖI: $error',
          ),
        ),
      ),
    ),
  );
}
