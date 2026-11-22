import 'dart:async';

import 'package:flutter/material.dart';

import '../repositories/member_repository.dart';
import 'home_page.dart';
import 'server_settings_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false, _busy = false;
  String? _message;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (_register) {
        await MemberRepository.register(
          _name.text,
          _email.text,
          _password.text,
        );
        if (!mounted) return;
        setState(() {
          _register = false;
          _message = 'Đăng ký thành công. Bạn có thể đăng nhập.';
        });
        _password.clear();
      } else {
        final member = await MemberRepository.login(
          _email.text,
          _password.text,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage(member: member)),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(
          () => _message = 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = error.toString().startsWith('Exception: ')
              ? error.toString().replaceFirst('Exception: ', '')
              : 'Không kết nối được máy chủ. Kiểm tra Wi-Fi và mục Kết nối máy chủ.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Khảo sát doanh nghiệp'),
      actions: [
        IconButton(
          tooltip: 'Kết nối máy chủ',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _busy
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServerSettingsPage()),
                ),
        ),
      ],
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.poll_outlined, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                Text(
                  _register ? 'Tạo tài khoản' : 'Đăng nhập',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                if (_register) ...[
                  TextFormField(
                    controller: _name,
                    enabled: !_busy,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                    validator: (v) => (v ?? '').trim().length < 2
                        ? 'Họ tên ít nhất 2 ký tự'
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch((v ?? '').trim())
                      ? null
                      : 'Email không hợp lệ',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  validator: (v) =>
                      (v ?? '').length < 8 || (v ?? '').length > 64
                      ? 'Mật khẩu từ 8 đến 64 ký tự'
                      : null,
                ),
                const SizedBox(height: 20),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_message!),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(
                    _busy
                        ? 'Đang xử lý...'
                        : _register
                        ? 'Đăng ký'
                        : 'Đăng nhập',
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _register = !_register;
                          _message = null;
                          _form.currentState?.reset();
                        }),
                  child: Text(
                    _register
                        ? 'Đã có tài khoản? Đăng nhập'
                        : 'Chưa có tài khoản? Đăng ký',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
