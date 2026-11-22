import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survey_app/local/local_database.dart';
import 'package:survey_app/pages/response_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android: lưu đủ loại câu trả lời, mở lại nháp offline và tách tài khoản',
    (tester) async {
      // Database kiểm thử riêng, không mở hoặc thay dữ liệu business_survey.db.
      final path = join(
        await getDatabasesPath(),
        'business_survey_device_check.db',
      );
      const memberId = -1000, itemId = -2000, campaignId = -3000;
      try {
        await LocalDatabase.open(databasePath: path);
        await LocalDatabase.clearDrafts(memberId);
        final payload = {
          'survey': {
            'surveyId': -4000,
            'categoryId': 1,
            'categoryName': 'Kiểm thử',
            'title': 'Bài kiểm thử nháp trên Android',
            'description': 'Dữ liệu tạm',
            'imagePath': '',
            'isUsed': true,
            'questions': [
              {
                'id': 1,
                'title': 'Góp ý',
                'type': 'text',
                'required': true,
                'options': <String>[],
              },
              {
                'id': 2,
                'title': 'Hài lòng',
                'type': 'single',
                'required': false,
                'options': ['Có', 'Không'],
              },
              {
                'id': 3,
                'title': 'Quan tâm',
                'type': 'multiple',
                'required': true,
                'options': ['Giá', 'Chất lượng', 'Dịch vụ'],
              },
              {
                'id': 4,
                'title': 'Đánh giá',
                'type': 'rating',
                'required': false,
                'options': <String>[],
              },
            ],
          },
          'answers': <String, dynamic>{},
          'submissionId': '11111111-1111-4111-8111-111111111111',
        };
        await LocalDatabase.saveDraft(
          memberId,
          itemId,
          campaignId,
          jsonEncode(payload),
        );
        Future<void> openPage() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ResponsePage(
                memberId: memberId,
                campaignId: campaignId,
                itemId: itemId,
                surveyId: -4000,
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        Future<void> reveal(Finder finder) async {
          await tester.scrollUntilVisible(
            finder,
            160,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 30,
          );
          await tester.pumpAndSettle();
        }

        await openPage();
        expect(find.text('Bài kiểm thử nháp trên Android'), findsOneWidget);
        await tester.enterText(
          find.byType(TextFormField).first,
          'Góp ý đã lưu trên điện thoại',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final single = find.byType(DropdownButtonFormField<String>);
        await reveal(single);
        await tester.tap(single);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Có').last);
        await tester.pumpAndSettle();
        for (final label in ['Giá', 'Chất lượng']) {
          final checkbox = find.widgetWithText(CheckboxListTile, label);
          await reveal(checkbox);
          await tester.tap(checkbox);
          await tester.pumpAndSettle();
        }
        final rating = find.byType(DropdownButtonFormField<int>);
        await reveal(rating);
        await tester.tap(rating);
        await tester.pumpAndSettle();
        await tester.tap(find.text('5 điểm').last);
        await tester.pumpAndSettle();
        final save = find.text('Lưu nháp SQLite');
        await reveal(save);
        await tester.tap(save);
        await tester.pumpAndSettle();

        var row = await LocalDatabase.draft(memberId, itemId);
        var restored = jsonDecode(row!['payload_json'] as String) as Map;
        expect(restored['answers'], {
          '1': 'Góp ý đã lưu trên điện thoại',
          '2': 'Có',
          '3': ['Giá', 'Chất lượng'],
          '4': 5,
        });
        expect(await LocalDatabase.drafts(memberId + 1), isEmpty);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await LocalDatabase.close();
        await LocalDatabase.open(databasePath: path);
        await openPage();
        expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .initialValue,
          'Góp ý đã lưu trên điện thoại',
        );
        await reveal(single);
        expect(
          tester.widget<DropdownButtonFormField<String>>(single).initialValue,
          'Có',
        );
        await tester.tap(find.text('Bỏ câu trả lời').first);
        await tester.pumpAndSettle();
        expect(
          tester.widget<DropdownButtonFormField<String>>(single).initialValue,
          isNull,
        );
        await reveal(rating);
        expect(
          tester.widget<DropdownButtonFormField<int>>(rating).initialValue,
          5,
        );
        await tester.tap(find.text('Bỏ câu trả lời').last);
        await tester.pumpAndSettle();
        expect(
          tester.widget<DropdownButtonFormField<int>>(rating).initialValue,
          isNull,
        );
        await reveal(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        row = await LocalDatabase.draft(memberId, itemId);
        restored = jsonDecode(row!['payload_json'] as String) as Map;
        expect((restored['answers'] as Map).containsKey('2'), isFalse);
        expect((restored['answers'] as Map).containsKey('4'), isFalse);
        expect(restored['submissionId'], payload['submissionId']);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await LocalDatabase.close();
        // Chỉ xóa đúng file database kiểm thử đã chỉ định, không xóa thư mục.
        await deleteDatabase(path);
      }
    },
  );
}
