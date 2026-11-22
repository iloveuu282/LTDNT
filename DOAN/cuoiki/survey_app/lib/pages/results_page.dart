import 'package:flutter/material.dart';

import '../repositories/campaign_repository.dart';
import '../widgets/common.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
    required this.campaignId,
    required this.itemId,
    required this.title,
  });
  final int campaignId, itemId;
  final String title;
  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Map<String, dynamic>? _data;
  bool _busy = true;
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
      final data = await CampaignRepository.results(
        widget.campaignId,
        widget.itemId,
      );
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _data?['total'] as int? ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả khảo sát'),
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
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Tổng phản hồi: $total'),
                if (_error != null) Text(_error!),
                ...((_data?['questions'] as List?) ?? []).map(
                  (q) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (q['type'] == 'rating')
                            Text(
                              q['average'] == null
                                  ? 'Chưa có đánh giá'
                                  : 'Điểm trung bình: ${(q['average'] as num).toStringAsFixed(2)}/5',
                            ),
                          if (q['type'] == 'text')
                            ...(q['texts'] as List).map(
                              (t) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text('• $t'),
                              ),
                            ),
                          if (q['type'] == 'single' || q['type'] == 'multiple')
                            ...(q['options'] as List).map(
                              (o) => Text(
                                '${o['label']}: ${o['count']} (${total == 0 ? '0' : ((o['count'] as int) * 100 / total).toStringAsFixed(1)}%)',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
