import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;
  static Future<Database> open({String? databasePath}) async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      databasePath ?? join(await getDatabasesPath(), 'business_survey.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE survey_drafts (
          member_id INTEGER NOT NULL, survey_id INTEGER NOT NULL,
          answers_json TEXT NOT NULL, updated_at TEXT NOT NULL,
          PRIMARY KEY (member_id, survey_id)
        )
      ''');
        await _createDrafts(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createDrafts(db);
      },
    );
    return _database!;
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  static Future<void> _createDrafts(Database db) => db.execute('''
    CREATE TABLE response_drafts (
      member_id INTEGER NOT NULL, item_id INTEGER NOT NULL, campaign_id INTEGER NOT NULL,
      payload_json TEXT NOT NULL, updated_at TEXT NOT NULL,
      PRIMARY KEY(member_id,item_id)
    )
  ''');
  static Future<void> saveDraft(
    int memberId,
    int itemId,
    int campaignId,
    String payload,
  ) async {
    final db = await open();
    await db.insert('response_drafts', {
      'member_id': memberId,
      'item_id': itemId,
      'campaign_id': campaignId,
      'payload_json': payload,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, Object?>?> draft(int memberId, int itemId) async {
    final rows = await (await open()).query(
      'response_drafts',
      where: 'member_id=? AND item_id=?',
      whereArgs: [memberId, itemId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, Object?>>> drafts(int memberId) async =>
      (await open()).query(
        'response_drafts',
        where: 'member_id=?',
        whereArgs: [memberId],
        orderBy: 'updated_at DESC',
      );
  static Future<void> deleteDraft(int memberId, int itemId) async {
    await (await open()).delete(
      'response_drafts',
      where: 'member_id=? AND item_id=?',
      whereArgs: [memberId, itemId],
    );
  }

  static Future<void> clearDrafts(int memberId) async {
    final db = await open();
    await db.delete(
      'survey_drafts',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    await db.delete(
      'response_drafts',
      where: 'member_id=?',
      whereArgs: [memberId],
    );
  }
}
