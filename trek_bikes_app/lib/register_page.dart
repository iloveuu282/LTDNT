import 'package:flutter/material.dart';
import 'package:trek_bikes_app/member.dart';
import 'package:trek_bikes_app/member_repository.dart';
class RegisterPage extends StatefulWidget {
  final String _title;
  const RegisterPage({super.key, required String title}) : _title = title;
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
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
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextFormField(
              controller: _givenNameController,
              decoration: const InputDecoration(labelText: 'GivenName'),
            ),
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            ElevatedButton.icon(
              onPressed: _register,
              label: const Text('Register'),
              icon: const Icon(Icons.save),
            ),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    );
  }
  void _register() async {
    var obj = Member(
      id: null,
      email: _emailController.text,
      password: _passwordController.text,
      givenName: _givenNameController.text,
      surname: _surnameController.text,
      role: 0,
    );
    int ret = await MemberRepository.save(obj);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register Success')),
      );
    } else {
      setState(() {
        _error = 'Register Failed';
      });
    }
  }
}