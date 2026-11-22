import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/campaign_repository.dart';
import '../widgets/common.dart';
import 'response_page.dart';
import 'results_page.dart';

class CampaignDetailsPage extends StatefulWidget {
  const CampaignDetailsPage({
    super.key,
    required this.campaignId,
    required this.memberId,
    required this.admin,
  });
  final int campaignId, memberId;
  final bool admin;
  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage> {
  Campaign? _campaign;
  List<CampaignItem> _items = [];
  bool _busy = true, _canManage = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = await CampaignRepository.details(widget.campaignId);
      if (mounted) {
        setState(() {
          _campaign = Campaign.fromMap(
            Map<String, dynamic>.from(data['campaign'] as Map),
          );
          _items = (data['items'] as List)
              .map(
                (m) =>
                    CampaignItem.fromMap(Map<String, dynamic>.from(m as Map)),
              )
              .toList();
          _canManage = data['canManage'] as bool;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _status(String status) async {
    if (!await confirmAction(
          context,
          'Đổi trạng thái?',
          Campaign.statusText(status),
        ) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await CampaignRepository.status(widget.campaignId, status);
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

  @override
  Widget build(BuildContext context) {
    final campaign = _campaign;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chiến dịch'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) Text(_error!),
                if (campaign != null) ...[
                  Text(
                    '#${campaign.campaignId} • ${campaign.title}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('Người tạo: ${campaign.fullName}'),
                  Text('Trạng thái: ${Campaign.statusText(campaign.status)}'),
                  if (widget.admin)
                    Wrap(
                      spacing: 8,
                      children: [
                        if (campaign.status == 'Pending') ...[
                          FilledButton(
                            onPressed: () => _status('Active'),
                            child: const Text('Mở chiến dịch'),
                          ),
                          OutlinedButton(
                            onPressed: () => _status('Cancelled'),
                            child: const Text('Hủy chiến dịch'),
                          ),
                        ],
                        if (campaign.status == 'Active')
                          FilledButton(
                            onPressed: () => _status('Closed'),
                            child: const Text('Đóng chiến dịch'),
                          ),
                      ],
                    ),
                  const Divider(),
                  ..._items.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${item.responseCount}/${item.targetCount} phản hồi',
                            ),
                            if (item.hasResponded)
                              const Text('Bạn đã trả lời.'),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (campaign.status == 'Active' &&
                                    !item.hasResponded &&
                                    item.responseCount < item.targetCount)
                                  FilledButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ResponsePage(
                                            memberId: widget.memberId,
                                            campaignId: widget.campaignId,
                                            itemId: item.itemId,
                                            surveyId: item.surveyId,
                                          ),
                                        ),
                                      );
                                      if (mounted) await _load();
                                    },
                                    child: const Text('Trả lời khảo sát'),
                                  ),
                                if (_canManage)
                                  OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ResultsPage(
                                          campaignId: widget.campaignId,
                                          itemId: item.itemId,
                                          title: item.title,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Xem kết quả'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
