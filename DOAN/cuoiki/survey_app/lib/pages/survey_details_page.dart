import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/survey_repository.dart';
import '../repositories/campaign_repository.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import 'survey_edit_page.dart';

class SurveyDetailsPage extends StatefulWidget {
  const SurveyDetailsPage({
    super.key,
    required this.surveyId,
    required this.admin,
  });
  final int surveyId;
  final bool admin;
  @override
  State<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

class _SurveyDetailsPageState extends State<SurveyDetailsPage> {
  Survey? _survey;
  bool _busy = true;
  String? _error;
  List<Survey> _related = [];
  int _relatedPage = 1, _relatedTotal = 0;
  bool _relatedBusy = false;
  String? _relatedError;
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
      final survey = await SurveyRepository.details(widget.surveyId);
      if (mounted) setState(() => _survey = survey);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted && _error == null) {
      _relatedPage = 1;
      await _loadRelated();
    }
  }

  Future<void> _loadRelated() async {
    setState(() {
      _relatedBusy = true;
      _relatedError = null;
    });
    try {
      final data = await SurveyRepository.related(
        widget.surveyId,
        _relatedPage,
      );
      if (mounted) {
        setState(() {
          _related = data.items;
          _relatedTotal = data.total;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _relatedError = errorText(e));
    } finally {
      if (mounted) setState(() => _relatedBusy = false);
    }
  }

  Future<void> _addPlan() async {
    setState(() => _busy = true);
    try {
      final plan = await CampaignRepository.plan();
      if (!plan.any((p) => p.surveyId == widget.surveyId)) {
        await CampaignRepository.putPlan(widget.surveyId, 1);
      }
      if (mounted) {
        showMessage(
          context,
          'Mẫu đã có trong kế hoạch. Bạn có thể đổi số phản hồi mục tiêu tại đó.',
        );
      }
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (!await confirmAction(
          context,
          'Xóa mẫu khảo sát?',
          'Mẫu và ảnh đại diện sẽ được xóa. Mẫu đã dùng trong chiến dịch không được xóa.',
        ) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await SurveyRepository.delete(widget.surveyId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showMessage(context, errorText(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final survey = _survey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết mẫu khảo sát'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : survey == null
          ? Center(child: Text(_error ?? 'Không tìm thấy mẫu.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Image.network(
                  ApiService.imageUrl(survey.imagePath),
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported_outlined, size: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  survey.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(survey.categoryName),
                const SizedBox(height: 8),
                Text(survey.description),
                FilledButton.icon(
                  onPressed: _addPlan,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Thêm vào kế hoạch'),
                ),
                if (widget.admin)
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: survey.isUsed
                            ? null
                            : () async {
                                if (await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SurveyEditPage(survey: survey),
                                          ),
                                        ) ==
                                        true &&
                                    mounted) {
                                  await _load();
                                }
                              },
                        child: const Text('Sửa mẫu'),
                      ),
                      OutlinedButton(
                        onPressed: _delete,
                        child: const Text('Xóa mẫu'),
                      ),
                    ],
                  ),
                if (survey.isUsed)
                  const Text(
                    'Mẫu đã triển khai: khóa sửa để giữ nguyên nội dung các phản hồi.',
                  ),
                const Divider(),
                Text(
                  'Nội dung câu hỏi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ...survey.questions.asMap().entries.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${e.key + 1}. ${e.value.title}${e.value.required ? ' *' : ''}',
                    ),
                    subtitle: Text(
                      '${QuestionDialog.labels[e.value.type]}${e.value.options.isEmpty ? '' : '\n${e.value.options.join(' • ')}'}',
                    ),
                  ),
                ),
                const Divider(),
                Text(
                  'Mẫu khảo sát liên quan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Các mẫu khác cùng danh mục, mới nhất trước.'),
                if (_relatedBusy)
                  const Center(child: CircularProgressIndicator())
                else if (_relatedError != null) ...[
                  Text(_relatedError!),
                  TextButton(
                    onPressed: _loadRelated,
                    child: const Text('Thử lại'),
                  ),
                ] else ...[
                  if (_related.isEmpty) const Text('Chưa có mẫu liên quan.'),
                  ..._related.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.categoryName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurveyDetailsPage(
                                surveyId: item.surveyId,
                                admin: widget.admin,
                              ),
                            ),
                          );
                          if (mounted) await _load();
                        },
                      ),
                    ),
                  ),
                  PageButtons(
                    page: _relatedPage,
                    total: _relatedTotal,
                    onChange: (p) {
                      _relatedPage = p;
                      _loadRelated();
                    },
                  ),
                ],
              ],
            ),
    );
  }
}
