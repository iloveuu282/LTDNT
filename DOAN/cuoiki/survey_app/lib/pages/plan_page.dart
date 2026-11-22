import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/campaign_repository.dart';
import '../widgets/common.dart';
import 'campaign_details_page.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.admin, required this.memberId});
  final bool admin;
  final int memberId;
  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final String _requestId = CampaignRepository.newId();
  List<PlanItem> _items = [];
  bool _busy = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final items = await CampaignRepository.plan();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _target(PlanItem item) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _TargetDialog(initial: item.targetCount),
    );
    if (value == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await CampaignRepository.putPlan(item.surveyId, value);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(e);
        });
      }
    }
  }

  Future<void> _remove(PlanItem item) async {
    if (!await confirmAction(context, 'Bỏ mẫu khỏi kế hoạch?', item.title) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await CampaignRepository.removePlan(item.surveyId);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(e);
        });
      }
    }
  }

  Future<void> _checkout() async {
    if (!_form.currentState!.validate()) return;
    if (!await confirmAction(
          context,
          'Xác nhận triển khai?',
          'Tạo chiến dịch từ các mẫu và số phản hồi mục tiêu hiện tại. Nội dung mẫu sẽ được khóa sửa.',
        ) ||
        !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await CampaignRepository.checkout(
        _title.text.trim(),
        _requestId,
      );
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CampaignDetailsPage(
            campaignId: id,
            memberId: widget.memberId,
            admin: widget.admin,
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch triển khai'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null) Text(_error!),
                  Text(
                    '${_items.length} mẫu • ${_items.fold<int>(0, (sum, item) => sum + item.targetCount)} phản hồi mục tiêu',
                  ),
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Kế hoạch trống. Hãy thêm mẫu từ trang chủ.'),
                    ),
                  ..._items.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          'Mục tiêu: ${item.targetCount} phản hồi',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _target(item),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Sửa số lượng',
                            ),
                            IconButton(
                              onPressed: () => _remove(item),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Bỏ mẫu',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_items.isNotEmpty) ...[
                    TextFormField(
                      controller: _title,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Tên chiến dịch',
                      ),
                      validator: (v) => (v ?? '').trim().length < 2
                          ? 'Tên ít nhất 2 ký tự'
                          : null,
                    ),
                    FilledButton(
                      onPressed: _checkout,
                      child: const Text('Xác nhận tạo chiến dịch'),
                    ),
                    const Text(
                      'Chiến dịch mới ở trạng thái Chờ duyệt. Admin sẽ mở để nhận phản hồi.',
                    ),
                  ],
                ],
              ),
            ),
    ),
  );
}

class _TargetDialog extends StatefulWidget {
  const _TargetDialog({required this.initial});
  final int initial;
  @override
  State<_TargetDialog> createState() => _TargetDialogState();
}

class _TargetDialogState extends State<_TargetDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _count;
  @override
  void initState() {
    super.initState();
    _count = TextEditingController(text: '${widget.initial}');
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Số phản hồi mục tiêu'),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _count,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Từ 1 đến 100000'),
        validator: (v) {
          final n = int.tryParse(v ?? '');
          return n == null || n < 1 || n > 100000
              ? 'Nhập số nguyên từ 1 đến 100000'
              : null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, int.parse(_count.text));
          }
        },
        child: const Text('Lưu'),
      ),
    ],
  );
}
