import 'package:flutter/material.dart';

import '../repositories/member_repository.dart';
import '../services/session_helper.dart';
import '../local/local_database.dart';
import 'login_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.memberId});
  final int memberId;
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await MemberRepository.changePassword(_current.text, _next.text);
      await SessionHelper.clear();
      await LocalDatabase.clearDrafts(widget.memberId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.'),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đổi mật khẩu')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _current,
              enabled: !_busy,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Nhập mật khẩu hiện tại' : null,
            ),
            TextFormField(
              controller: _next,
              enabled: !_busy,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              validator: (v) {
                if ((v ?? '').length < 8 || (v ?? '').length > 64) {
                  return 'Mật khẩu từ 8 đến 64 ký tự';
                }
                return v == _current.text
                    ? 'Mật khẩu mới phải khác mật khẩu hiện tại'
                    : null;
              },
            ),
            TextFormField(
              controller: _confirm,
              enabled: !_busy,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nhập lại mật khẩu mới',
              ),
              validator: (v) =>
                  v != _next.text ? 'Mật khẩu xác nhận không khớp' : null,
            ),
            const SizedBox(height: 24),
            if (_error != null) Text(_error!),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Đang lưu...' : 'Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    ),
  );
}
