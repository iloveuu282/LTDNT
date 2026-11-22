import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:survey_app/services/api_service.dart';
import 'package:survey_app/services/session_helper.dart';
import 'package:survey_app/pages/server_settings_page.dart';

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await ApiService.initialize();
  });

  test(
    'Địa chỉ Wi-Fi được chuẩn hóa và chặn đường dẫn hoặc thông tin đăng nhập',
    () {
      expect(
        ApiService.normalizeUrl(' http://192.168.1.7:5080/ '),
        'http://192.168.1.7:5080',
      );
      expect(
        ApiService.normalizeUrl('https://survey.example.com'),
        'https://survey.example.com',
      );
      for (final url in [
        '192.168.1.7:5080',
        'ftp://server',
        'http://server/api',
        'http://user:pass@server',
        'http://server?token=abc',
        'http://server:99999',
      ]) {
        expect(() => ApiService.normalizeUrl(url), throwsFormatException);
      }
    },
  );

  test('Địa chỉ máy chủ giữ sau khi mở lại và đăng xuất', () async {
    await ApiService.saveServer('http://192.168.1.7:5080/');
    await SessionHelper.clear();
    await ApiService.initialize();
    expect(ApiService.baseUrl, 'http://192.168.1.7:5080');
  });

  testWidgets(
    'Màn hình kết nối chặn địa chỉ sai và cuộn khi bàn phím mở ngang',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(850, 393);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(const MaterialApp(home: ServerSettingsPage()));
      await tester.scrollUntilVisible(
        find.byType(TextFormField),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextFormField), 'wrong');
      await tester.scrollUntilVisible(
        find.text('Lưu và sử dụng'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Lưu và sử dụng'));
      await tester.pump();
      expect(
        find.text(
          'Nhập địa chỉ http:// hoặc https:// và cổng, không thêm /api.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
