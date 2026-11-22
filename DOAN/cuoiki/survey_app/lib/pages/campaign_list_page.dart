import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/campaign_repository.dart';
import '../widgets/common.dart';
import 'campaign_details_page.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({
    super.key,
    required this.memberId,
    required this.admin,
    this.open = false,
  });
  final int memberId;
  final bool admin, open;
  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  final _search = TextEditingController();
  List<Campaign> _items = [];
  DateTime? _fromDate, _toDate;
  int _page = 1, _total = 0;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) {
      showMessage(context, 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = await CampaignRepository.getPage(
        _page,
        widget.open,
        search: _search.text.trim(),
        fromDate: _fromDate == null ? null : _date(_fromDate!),
        toDate: _toDate == null ? null : _date(_toDate!),
      );
      if (mounted) {
        setState(() {
          _items = data.items;
          _total = data.total;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apply() {
    FocusScope.of(context).unfocus();
    _page = 1;
    _load();
  }

  Future<void> _pickDate(bool from) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (from ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (from) {
        _fromDate = selected;
      } else {
        _toDate = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.open
            ? 'Khảo sát đang mở'
            : widget.admin
            ? 'Quản lý chiến dịch'
            : 'Chiến dịch của tôi',
      ),
      actions: [
        IconButton(
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        TextField(
          controller: _search,
          enabled: !_busy,
          maxLength: 150,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _apply(),
          decoration: InputDecoration(
            labelText: 'Tìm theo tên hoặc mã chiến dịch',
            suffixIcon: IconButton(
              onPressed: _busy ? null : _apply,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        const Text('Ngày tạo (giờ Việt Nam)'),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy ? null : () => _pickDate(true),
              child: Text(
                'Từ: ${_fromDate == null ? 'Chưa chọn' : _date(_fromDate!)}',
              ),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _pickDate(false),
              child: Text(
                'Đến: ${_toDate == null ? 'Chưa chọn' : _date(_toDate!)}',
              ),
            ),
            FilledButton(
              onPressed: _busy ? null : _apply,
              child: const Text('Áp dụng'),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      _search.clear();
                      _fromDate = null;
                      _toDate = null;
                      _apply();
                    },
              child: const Text('Xóa bộ lọc'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_busy)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(_error!)
        else if (_items.isEmpty)
          const Text('Không có chiến dịch phù hợp.')
        else
          ..._items.map(
            (c) => Card(
              child: ListTile(
                title: Text('#${c.campaignId} • ${c.title}'),
                subtitle: Text(
                  '${Campaign.statusText(c.status)} • ${c.fullName}\n${DateTime.parse('${c.createdAt}Z').toLocal().toString().substring(0, 16)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampaignDetailsPage(
                        campaignId: c.campaignId,
                        memberId: widget.memberId,
                        admin: widget.admin,
                      ),
                    ),
                  );
                  if (mounted) await _load();
                },
              ),
            ),
          ),
        if (!_busy && _error == null)
          PageButtons(
            page: _page,
            total: _total,
            onChange: (p) {
              _page = p;
              _load();
            },
          ),
      ],
    ),
  );
}
