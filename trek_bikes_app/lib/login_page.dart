
import 'package:flutter/material.dart';
import 'package:trek_bikes_app/member_repository.dart';
import 'package:trek_bikes_app/login_reponse.dart';
import 'package:trek_bikes_app/session_helper.dart';

class LoginPage extends StatefulWidget {
  final String _title;

const LoginPage({
  super.key,
  required String title,
}) : _title = title;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton.icon(
              onPressed: _login,
              label: Text('Login'),
              icon: Icon(Icons.login),
            ),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    );
  }

  void _login() async {
    LoginReponse? reponse = await MemberRepository.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (reponse != null) {
      if (reponse.success) {
        await SessionHelper.save(
          _emailController.text.trim(),
          reponse.token!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reponse.message)),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = reponse.message;
        });
      }
    } else {
      setState(() {
        _error = "Invalid";
      });
    }
  }
}
