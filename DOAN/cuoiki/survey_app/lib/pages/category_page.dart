import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../models/survey.dart';
import '../repositories/survey_repository.dart';
import '../widgets/common.dart';
import '../widgets/category_image.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> _items = [];
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
      final data = await SurveyRepository.categories();
      if (mounted) setState(() => _items = data);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([Category? item]) async {
    if (await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => _CategoryDialog(item: item),
            ) ==
            true &&
        mounted) {
      await _load();
    }
  }

  Future<void> _delete(Category item) async {
    if (!await confirmAction(context, 'Xóa danh mục?', item.categoryName) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await SurveyRepository.deleteCategory(item.categoryId);
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản lý danh mục'),
      actions: [
        IconButton(
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _busy ? null : () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: _busy
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              if (_error != null) Text(_error!),
              if (_items.isEmpty) const Text('Chưa có danh mục.'),
              ..._items.map(
                (item) => Card(
                  child: ListTile(
                    leading: CategoryImage(path: item.imagePath),
                    title: Text(item.categoryName),
                    subtitle: Text(item.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _edit(item),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Sửa',
                        ),
                        IconButton(
                          onPressed: () => _delete(item),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Xóa',
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

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.item});
  final Category? item;
  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _description;
  bool _busy = false;
  XFile? _image;
  bool _removeImage = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.categoryName);
    _description = TextEditingController(text: widget.item?.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SurveyRepository.saveCategory(
        widget.item?.categoryId,
        _name.text.trim(),
        _description.text.trim(),
        image: _image,
        removeImage: _removeImage,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(e);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    setState(() => _busy = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        if (await image.length() > 5242880) {
          if (mounted) setState(() => _error = 'Ảnh tối đa 5 MB.');
        } else if (mounted) {
          setState(() {
            _image = image;
            _removeImage = false;
            _error = null;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không chọn được ảnh. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      scrollable: true,
      title: Text(widget.item == null ? 'Thêm danh mục' : 'Sửa danh mục'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_image != null)
                Image.file(
                  File(_image!.path),
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_outlined),
                )
              else
                Center(
                  child: CategoryImage(
                    path: _removeImage ? null : widget.item?.imagePath,
                    size: 100,
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Ảnh đại diện PNG/JPEG, tối đa 5 MB. Có thể để trống.',
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Chọn ảnh'),
                  ),
                  if (_image != null ||
                      (!_removeImage && widget.item?.imagePath != null))
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _image = null;
                              _removeImage = true;
                            }),
                      child: const Text('Bỏ ảnh'),
                    ),
                  if (_removeImage && widget.item?.imagePath != null)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _removeImage = false),
                      child: const Text('Giữ ảnh cũ'),
                    ),
                ],
              ),
              TextFormField(
                controller: _name,
                enabled: !_busy,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Tên danh mục'),
                validator: (v) =>
                    (v ?? '').trim().length < 2 ? 'Tên ít nhất 2 ký tự' : null,
              ),
              TextFormField(
                controller: _description,
                enabled: !_busy,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              if (_error != null) Text(_error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    ),
  );
}
