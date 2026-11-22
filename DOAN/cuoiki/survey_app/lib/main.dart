import 'package:flutter/material.dart';

import 'local/local_database.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'models/member.dart';
import 'services/session_helper.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? error;
  try {
    await LocalDatabase.open();
  } catch (_) {
    error = 'Không mở được dữ liệu trên điện thoại. Vui lòng khởi động lại ứng dụng.';
  }
  try {
    await ApiService.initialize();
  } catch (_) {
    /* Vẫn cho phép mở nháp khi bộ nhớ bảo mật tạm lỗi. */
  }
  runApp(SurveyApp(startupError: error));
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key, this.startupError});
  final String? startupError;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Khảo sát doanh nghiệp',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    builder: (context, child) =>
        SafeArea(top: false, child: child ?? const SizedBox.shrink()),
    home: startupError == null
        ? const _SessionPage()
        : Scaffold(body: Center(child: Text(startupError!))),
  );
}

class _SessionPage extends StatefulWidget {
  const _SessionPage();
  @override
  State<_SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<_SessionPage> {
  late final Future<Member?> _member = SessionHelper.restore();
  @override
  Widget build(BuildContext context) => FutureBuilder<Member?>(
    future: _member,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snapshot.data == null
          ? const LoginPage()
          : HomePage(member: snapshot.data!);
    },
  );
}
