import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:survey_app/local/local_database.dart';

void main() {
  late Directory directory;
  late String path;
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'business_survey_sqlite_test_',
    );
    path = join(directory.path, 'drafts.db');
  });
  tearDown(() async {
    await LocalDatabase.close();
    // Chỉ xóa thư mục tạm do chính test vừa tạo.
    expect(
      basename(directory.path).startsWith('business_survey_sqlite_test_'),
      isTrue,
    );
    await directory.delete(recursive: true);
  });

  test(
    'Nháp giữ qua khởi động lại, tách tài khoản và xóa đúng tài khoản',
    () async {
      await LocalDatabase.open(databasePath: path);
      await LocalDatabase.saveDraft(
        1,
        7,
        3,
        jsonEncode({
          'answers': {'1': 'Nội dung nháp'},
          'submissionId': 'same-id',
        }),
      );
      await LocalDatabase.saveDraft(
        2,
        7,
        3,
        jsonEncode({
          'answers': {'1': 'Người khác'},
        }),
      );
      await LocalDatabase.close();
      await LocalDatabase.open(databasePath: path);
      final draft = await LocalDatabase.draft(1, 7);
      expect(
        (jsonDecode(draft!['payload_json'] as String) as Map)['submissionId'],
        'same-id',
      );
      expect(await LocalDatabase.drafts(1), hasLength(1));
      await LocalDatabase.saveDraft(
        1,
        7,
        3,
        jsonEncode({
          'answers': {'1': 'Đã cập nhật'},
        }),
      );
      expect(await LocalDatabase.drafts(1), hasLength(1));
      await LocalDatabase.clearDrafts(1);
      expect(await LocalDatabase.drafts(1), isEmpty);
      expect(await LocalDatabase.drafts(2), hasLength(1));
      await LocalDatabase.deleteDraft(2, 7);
      expect(await LocalDatabase.drafts(2), isEmpty);
    },
  );

  test(
    'Nâng SQLite từ bản 1 lên bản 2 giữ dữ liệu và thêm bảng nháp mới',
    () async {
      final old = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE survey_drafts(member_id INTEGER,survey_id INTEGER,answers_json TEXT,updated_at TEXT,PRIMARY KEY(member_id,survey_id))',
            );
            await db.insert('survey_drafts', {
              'member_id': 1,
              'survey_id': 2,
              'answers_json': '{}',
              'updated_at': 'before-upgrade',
            });
          },
        ),
      );
      await old.close();
      final upgraded = await LocalDatabase.open(databasePath: path);
      expect(await upgraded.query('survey_drafts'), hasLength(1));
      await LocalDatabase.saveDraft(1, 5, 3, '{}');
      expect(await LocalDatabase.drafts(1), hasLength(1));
    },
  );
}
