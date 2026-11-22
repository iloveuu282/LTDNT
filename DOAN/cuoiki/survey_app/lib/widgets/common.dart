import 'package:flutter/material.dart';

String errorText(Object error) =>
    error.toString().replaceFirst('Exception: ', '');
void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
Future<bool> confirmAction(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    ) ??
    false;

class PageButtons extends StatelessWidget {
  const PageButtons({
    super.key,
    required this.page,
    required this.total,
    required this.onChange,
  });
  final int page, total;
  final ValueChanged<int>? onChange;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: page > 1 && onChange != null
            ? () => onChange!(page - 1)
            : null,
        icon: const Icon(Icons.chevron_left),
      ),
      Text(
        'Trang $page / ${((total + 9) ~/ 10).clamp(1, 100000)} • $total kết quả',
      ),
      IconButton(
        onPressed: page * 10 < total && onChange != null
            ? () => onChange!(page + 1)
            : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}
