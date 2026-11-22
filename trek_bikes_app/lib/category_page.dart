import 'package:flutter/material.dart';
import 'package:trek_bikes_app/category.dart';
import 'package:trek_bikes_app/category_repository.dart';
class CategoryPage extends StatefulWidget {
  final String title;
  const CategoryPage({
    super.key,
    required this.title,
  });
  @override
  State<StatefulWidget> createState() => _CategoryPageState();
}
class _CategoryPageState extends State<CategoryPage> {
  List<Category> list = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  void _loadData() async {
    var data = await CategoryRepository.getCategories();
    if (!mounted) return;
    setState(() {
      list = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GridView.builder(
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemBuilder: (context, index) {
          Category item = list[index];
          return Row(
            children: [
              Text(item.name),
            ],
          );
        },
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _add,
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
  void _add() async {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Icon',
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                var obj = Category(
                  id: 0,
                  name: nameController.text,
                  title: titleController.text,
                  description: descriptionController.text,
                  icon: iconController.text,
                );
                _saveAdd(obj);
              },
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    iconController.dispose();
  }
void _saveAdd(Category obj) async {
  int ret = await CategoryRepository.add(obj);

  if (!mounted) return;

  if (ret > 0) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(content: Text('Insert success')),
        );

    _loadData();
    Navigator.pop(context, true);
  }
}}