import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../repositories/survey_repository.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import '../widgets/category_image.dart';
import 'survey_edit_page.dart';
import 'survey_details_page.dart';

class SurveyListView extends StatefulWidget {
  const SurveyListView({
    super.key,
    required this.admin,
    required this.onPlanChanged,
    this.header,
  });
  final bool admin;
  final VoidCallback onPlanChanged;
  final Widget? header;
  @override
  State<SurveyListView> createState() => _SurveyListViewState();
}

class _SurveyListViewState extends State<SurveyListView> {
  final _search = TextEditingController();
  List<Category> _categories = [];
  List<Survey> _items = [];
  int? _category;
  int _page = 1, _total = 0;
  bool _busy = true;
  String? _error;
  int _request = 0;
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

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final categories = await SurveyRepository.categories();
      if (_category != null &&
          !categories.any((c) => c.categoryId == _category)) {
        _category = null;
        _page = 1;
      }
      final data = await SurveyRepository.getPage(
        _page,
        _category,
        _search.text.trim(),
      );
      if (mounted && request == _request) {
        setState(() {
          _categories = categories;
          _items = data.items;
          _total = data.total;
        });
      }
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = errorText(e));
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _details(Survey survey) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SurveyDetailsPage(surveyId: survey.surveyId, admin: widget.admin),
      ),
    );
    if (mounted) {
      _page = 1;
      widget.onPlanChanged();
      await _load();
    }
  }

  Future<void> _add() async {
    if (await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const SurveyEditPage()),
            ) ==
            true &&
        mounted) {
      _page = 1;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.only(bottom: 16),
    children: [
      if (widget.header != null) widget.header!,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _search,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Tìm mẫu khảo sát',
                  counterText: '',
                ),
                onSubmitted: (_) {
                  _page = 1;
                  _load();
                },
              ),
            ),
            IconButton(
              onPressed: _busy
                  ? null
                  : () {
                      _page = 1;
                      _load();
                    },
              icon: const Icon(Icons.search),
              tooltip: 'Tìm kiếm',
            ),
            IconButton(
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Tải lại',
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _category,
                hint: const Text('Tất cả danh mục'),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Tất cả danh mục'),
                  ),
                  ..._categories.map(
                    (c) => DropdownMenuItem(
                      value: c.categoryId,
                      child: Row(
                        children: [
                          CategoryImage(path: c.imagePath, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.categoryName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: _busy
                    ? null
                    : (v) {
                        setState(() {
                          _category = v;
                          _page = 1;
                        });
                        _load();
                      },
              ),
            ),
            if (widget.admin)
              TextButton.icon(
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add),
                label: const Text('Thêm mẫu'),
              ),
          ],
        ),
      ),
      if (_busy)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_error != null)
        Padding(padding: const EdgeInsets.all(16), child: Text(_error!))
      else if (_items.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Chưa có mẫu phù hợp.'),
        )
      else
        ..._items.map(
          (item) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: ListTile(
              leading: Image.network(
                ApiService.imageUrl(item.imagePath),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported_outlined),
              ),
              title: Text(item.title),
              subtitle: Text(
                '${item.categoryName} • ${item.questions.length} câu hỏi',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _details(item),
            ),
          ),
        ),
      PageButtons(
        page: _page,
        total: _total,
        onChange: _busy
            ? null
            : (page) {
                _page = page;
                _load();
              },
      ),
    ],
  );
}
