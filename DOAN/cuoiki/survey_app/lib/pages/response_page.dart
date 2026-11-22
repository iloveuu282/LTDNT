import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/survey_repository.dart';
import '../repositories/campaign_repository.dart';
import '../local/local_database.dart';
import '../widgets/common.dart';

class ResponsePage extends StatefulWidget {
  const ResponsePage({
    super.key,
    required this.memberId,
    required this.campaignId,
    required this.itemId,
    required this.surveyId,
  });
  final int memberId, campaignId, itemId, surveyId;
  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  Survey? _survey;
  Map<String, dynamic> _answers = {};
  String _submissionId = CampaignRepository.newId();
  bool _loading = true, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final draft = await LocalDatabase.draft(widget.memberId, widget.itemId);
      Survey survey;
      if (draft != null) {
        final payload = jsonDecode(draft['payload_json'] as String) as Map;
        survey = Survey.fromMap(
          Map<String, dynamic>.from(payload['survey'] as Map),
        );
        _answers = Map<String, dynamic>.from(payload['answers'] as Map);
        _submissionId = payload['submissionId'] as String;
      } else {
        survey = await SurveyRepository.details(widget.surveyId);
      }
      if (mounted) setState(() => _survey = survey);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _store() async => LocalDatabase.saveDraft(
    widget.memberId,
    widget.itemId,
    widget.campaignId,
    jsonEncode({
      'survey': _survey!.toMap(),
      'answers': _answers,
      'submissionId': _submissionId,
    }),
  );
  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await _store();
      if (mounted) {
        showMessage(context, 'Đã lưu nháp trên điện thoại.');
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, 'Không lưu được nháp. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    for (final q in _survey!.questions) {
      final v = _answers['${q.id}'];
      if (q.required &&
          (v == null ||
              (v is String && v.trim().isEmpty) ||
              (v is List && v.isEmpty))) {
        showMessage(context, 'Chưa trả lời: ${q.title}');
        return;
      }
    }
    if (!await confirmAction(
          context,
          'Gửi phản hồi?',
          'Mỗi tài khoản gửi một lần cho mẫu này trong chiến dịch.',
        ) ||
        !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _store(); // Nếu mạng lỗi, nội dung vẫn còn trên điện thoại.
      await CampaignRepository.submit(
        widget.campaignId,
        widget.itemId,
        _submissionId,
        _answers,
      );
      await LocalDatabase.deleteDraft(widget.memberId, widget.itemId);
      if (mounted) {
        showMessage(context, 'Đã gửi phản hồi.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = '${errorText(e)}\nNháp vẫn được giữ trên điện thoại.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _question(Question q) {
    final key = '${q.id}';
    final value = _answers[key];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${q.title}${q.required ? ' *' : ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (q.type == 'text')
              TextFormField(
                key: ValueKey(key),
                initialValue: value as String? ?? '',
                maxLength: 2000,
                minLines: 1,
                maxLines: 5,
                onChanged: (v) => _answers[key] = v,
                decoration: const InputDecoration(labelText: 'Câu trả lời'),
              ),
            if (q.type == 'single')
              DropdownButtonFormField<String>(
                key: ValueKey('single-$key-$value'),
                initialValue: value as String?,
                isExpanded: true,
                hint: const Text('Chọn một đáp án'),
                items: q.options
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(o, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _answers[key] = v),
              ),
            if (q.type == 'multiple')
              ...q.options.map(
                (o) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o),
                  value: (value as List? ?? []).contains(o),
                  onChanged: (checked) => setState(() {
                    final selected = List<String>.from(value ?? []);
                    if (checked == true) {
                      selected.add(o);
                    } else {
                      selected.remove(o);
                    }
                    _answers[key] = selected;
                  }),
                ),
              ),
            if (q.type == 'rating')
              DropdownButtonFormField<int>(
                key: ValueKey('rating-$key-$value'),
                initialValue: value as int?,
                hint: const Text('Chọn điểm 1–5'),
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} điểm'),
                  ),
                ),
                onChanged: (v) => setState(() => _answers[key] = v),
              ),
            if (!q.required && q.type != 'text')
              TextButton(
                onPressed: () => setState(() => _answers.remove(key)),
                child: const Text('Bỏ câu trả lời'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Trả lời khảo sát')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _survey == null
          ? Center(child: Text(_error ?? 'Không tải được khảo sát.'))
          : AbsorbPointer(
              absorbing: _busy,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    _survey!.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    '* Bắt buộc. Hãy lưu nháp trước khi rời trang nếu chưa gửi.',
                  ),
                  if (_error != null) Text(_error!),
                  ..._survey!.questions.map(_question),
                  OutlinedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu nháp'),
                  ),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(_busy ? 'Đang xử lý...' : 'Gửi phản hồi'),
                  ),
                ],
              ),
            ),
    ),
  );
}
