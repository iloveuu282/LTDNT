import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:survey_app/main.dart';
import 'package:survey_app/models/member.dart';
import 'package:survey_app/pages/home_page.dart';
import 'package:survey_app/pages/change_password_page.dart';
import 'package:survey_app/pages/campaign_list_page.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets('Bộ lọc chiến dịch không tràn khi mở bàn phím ngang', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(850, 393);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      const MaterialApp(home: CampaignListPage(memberId: 1, admin: false)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#123');
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Xóa bộ lọc'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Trang chủ không tràn khi xoay ngang và mở bàn phím', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(850, 393);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(
          member: Member(
            memberId: 1,
            fullName: 'Admin kiểm thử',
            email: 'check@example.com',
            roleName: 'Admin',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    final search = find.byType(TextField);
    await tester.scrollUntilVisible(
      search,
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(search, 'Khảo sát');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Member không thấy quản trị, Admin thấy quản trị', (
    tester,
  ) async {
    for (final role in ['Member', 'Admin']) {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            member: Member(
              memberId: 1,
              fullName: 'Demo',
              email: 'demo@example.com',
              roleName: role,
            ),
          ),
        ),
      );
      expect(
        find.text('Thành viên và vai trò'),
        role == 'Admin' ? findsOneWidget : findsNothing,
      );
    }
  });

  testWidgets('Đổi mật khẩu chặn xác nhận không khớp trước khi gọi API', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChangePasswordPage(memberId: 1)),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Old@123456');
    await tester.enterText(fields.at(1), 'New@123456');
    await tester.enterText(fields.at(2), 'Different@123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Đổi mật khẩu'));
    await tester.pump();
    expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
  });
  testWidgets('Mở đăng ký từ đăng nhập', (tester) async {
    await tester.pumpWidget(const SurveyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Họ tên'), findsOneWidget);
    expect(find.text('Tạo tài khoản'), findsOneWidget);
  });
}
