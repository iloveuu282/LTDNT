import 'dart:convert';

import 'package:flutter/material.dart';

import '../local/local_database.dart';
import '../widgets/common.dart';
import 'response_page.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key, required this.memberId});
  final int memberId;
  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  List<Map<String, Object?>> _items = [];
  bool _busy = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await LocalDatabase.drafts(widget.memberId);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Không đọc được bản nháp trên điện thoại.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nháp trên điện thoại')),
    body: _busy
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Nháp lưu riêng cho tài khoản này. Đăng xuất sẽ xóa nháp; cần mạng để gửi phản hồi.',
              ),
              if (_error != null) Text(_error!),
              if (_items.isEmpty) const Text('Chưa có nháp.'),
              ..._items.map((row) {
                final payload =
                    jsonDecode(row['payload_json'] as String) as Map;
                final survey = payload['survey'] as Map;
                return Card(
                  child: ListTile(
                    title: Text(survey['title'] as String),
                    subtitle: Text(
                      'Chiến dịch #${row['campaign_id']} • ${row['updated_at'].toString().substring(0, 16).replaceFirst('T', ' ')}',
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResponsePage(
                            memberId: widget.memberId,
                            campaignId: row['campaign_id'] as int,
                            itemId: row['item_id'] as int,
                            surveyId: survey['surveyId'] as int,
                          ),
                        ),
                      );
                      if (mounted) await _load();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await confirmAction(
                              context,
                              'Xóa nháp?',
                              'Nội dung chưa gửi sẽ mất.',
                            ) &&
                            mounted) {
                          await LocalDatabase.deleteDraft(
                            widget.memberId,
                            row['item_id'] as int,
                          );
                          await _load();
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
  );
}
