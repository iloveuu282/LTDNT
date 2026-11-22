import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/survey.dart';
import '../repositories/survey_repository.dart';
import '../widgets/common.dart';

class SurveyEditPage extends StatefulWidget {
  const SurveyEditPage({super.key, this.survey});
  final Survey? survey;
  @override
  State<SurveyEditPage> createState() => _SurveyEditPageState();
}

class _SurveyEditPageState extends State<SurveyEditPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title, _description;
  List<Category> _categories = [];
  List<Question> _questions = [];
  int? _categoryId;
  XFile? _image;
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.survey?.title);
    _description = TextEditingController(text: widget.survey?.description);
    _categoryId = widget.survey?.categoryId;
    _questions = [...?widget.survey?.questions];
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await SurveyRepository.categories();
      if (mounted) {
        setState(() {
          _categories = items;
          if (_categoryId != null &&
              !items.any((c) => c.categoryId == _categoryId)) {
            _categoryId = null;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (image != null && mounted) setState(() => _image = image);
    } catch (e) {
      if (mounted) {
        showMessage(context, 'Không chọn được ảnh. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _editQuestion([int? index]) async {
    final result = await showDialog<Question>(
      context: context,
      builder: (_) => QuestionDialog(
        question: index == null ? null : _questions[index],
        id: index == null
            ? (_questions.fold<int>(0, (max, q) => q.id > max ? q.id : max) + 1)
            : _questions[index].id,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (index == null) {
          _questions.add(result);
        } else {
          _questions[index] = result;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_questions.isEmpty) {
      showMessage(context, 'Thêm ít nhất một câu hỏi.');
      return;
    }
    if (widget.survey == null && _image == null) {
      showMessage(context, 'Chọn ảnh đại diện PNG hoặc JPEG.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await SurveyRepository.save(
        widget.survey?.surveyId,
        _categoryId!,
        _title.text.trim(),
        _description.text.trim(),
        _questions,
        _image,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.survey == null ? 'Thêm mẫu khảo sát' : 'Sửa mẫu khảo sát',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AbsorbPointer(
              absorbing: _saving,
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null) Text(_error!),
                    if (_categories.isEmpty)
                      const Text('Chưa có danh mục. Hãy tạo danh mục trước.'),
                    TextFormField(
                      controller: _title,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Tên mẫu khảo sát',
                      ),
                      validator: (v) => (v ?? '').trim().length < 2
                          ? 'Tên ít nhất 2 ký tự'
                          : null,
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.categoryId,
                              child: Text(c.categoryName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                      validator: (v) => v == null ? 'Chọn danh mục' : null,
                    ),
                    TextFormField(
                      controller: _description,
                      maxLength: 2000,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Nhập mô tả' : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        _image?.name ??
                            (widget.survey == null
                                ? 'Chọn ảnh (bắt buộc)'
                                : 'Đổi ảnh (không chọn sẽ giữ ảnh cũ)'),
                      ),
                    ),
                    const Text('Ảnh PNG/JPEG, tối đa 5 MB.'),
                    const SizedBox(height: 16),
                    Text(
                      'Câu hỏi (${_questions.length}/50)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ..._questions.asMap().entries.map(
                      (e) => Card(
                        child: ListTile(
                          title: Text('${e.key + 1}. ${e.value.title}'),
                          subtitle: Text(
                            '${QuestionDialog.labels[e.value.type]}${e.value.required ? ' • Bắt buộc' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editQuestion(e.key),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _questions.removeAt(e.key)),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _questions.length < 50
                          ? () => _editQuestion()
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm câu hỏi'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _categories.isEmpty ? null : _save,
                      child: Text(_saving ? 'Đang lưu...' : 'Lưu mẫu khảo sát'),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );
}

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key, this.question, required this.id});
  final Question? question;
  final int id;
  static const labels = {
    'text': 'Văn bản',
    'single': 'Chọn một',
    'multiple': 'Chọn nhiều',
    'rating': 'Thang điểm 1–5',
  };
  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title, _options;
  late String _type;
  late bool _required;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.question?.title);
    _options = TextEditingController(text: widget.question?.options.join('\n'));
    _type = widget.question?.type ?? 'text';
    _required = widget.question?.required ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _options.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final options = (_type == 'single' || _type == 'multiple')
        ? _options.text
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
        : <String>[];
    Navigator.pop(
      context,
      Question(
        id: widget.id,
        title: _title.text.trim(),
        type: _type,
        required: _required,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nội dung câu hỏi'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'Câu hỏi'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Nhập câu hỏi' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: QuestionDialog.labels.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              SwitchListTile(
                title: const Text('Bắt buộc trả lời'),
                value: _required,
                onChanged: (v) => setState(() => _required = v),
              ),
              if (_type == 'single' || _type == 'multiple')
                TextFormField(
                  controller: _options,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Lựa chọn (mỗi dòng một mục)',
                  ),
                  validator: (v) {
                    final list = (v ?? '')
                        .split('\n')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    return list.length < 2 ||
                            list.length > 20 ||
                            list.toSet().length != list.length ||
                            list.any((s) => s.length > 200)
                        ? 'Cần 2–20 lựa chọn khác nhau, tối đa 200 ký tự/mục'
                        : null;
                  },
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(onPressed: _save, child: const Text('Lưu câu hỏi')),
    ],
  );
}
