import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});
  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController(text: ApiService.baseUrl);
  bool _busy = false;
  String? _message;
  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _check({bool save = false}) async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ApiService.checkServer(_address.text);
      if (save) await ApiService.saveServer(_address.text);
      if (!mounted) return;
      if (save) {
        showMessage(context, 'Đã lưu kết nối máy chủ.');
        Navigator.pop(context, true);
      } else {
        setState(
          () =>
              _message = 'Kết nối thành công. Nhấn Lưu để sử dụng địa chỉ này.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _message = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Kết nối máy chủ')),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.dns_outlined, size: 56, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'Sử dụng qua Wi-Fi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Điện thoại và máy tính chạy máy chủ cần cùng mạng Wi-Fi. Nhập địa chỉ máy tính để tiếp tục sử dụng sau khi rút cáp USB.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address,
                enabled: !_busy,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ máy chủ',
                  hintText: 'http://192.168.1.10:5080',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  try {
                    ApiService.normalizeUrl(value ?? '');
                    return null;
                  } catch (_) {
                    return 'Nhập địa chỉ http:// hoặc https:// và cổng, không thêm /api.';
                  }
                },
              ),
              const SizedBox(height: 12),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_message!),
                ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _check(),
                icon: const Icon(Icons.wifi_find),
                label: const Text('Kiểm tra kết nối'),
              ),
              FilledButton(
                onPressed: _busy ? null : () => _check(save: true),
                child: Text(_busy ? 'Đang kết nối...' : 'Lưu và sử dụng'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(
                        () => _address.text = 'http://localhost:5080',
                      ),
                child: const Text('Dùng kết nối USB'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Máy chủ cần tiếp tục chạy trên máy tính. Nếu mất mạng hoặc máy chủ dừng, bạn vẫn có thể đọc và sửa nháp đã lưu trên điện thoại, rồi gửi khi có kết nối trở lại.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
