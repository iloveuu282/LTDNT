import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CategoryImage extends StatelessWidget {
  const CategoryImage({super.key, this.path, this.size = 48});
  final String? path;
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
      width: size,
      height: size,
      child: path == null || path!.isEmpty
          ? const ColoredBox(
              color: Color(0xFFE0F2F1),
              child: Icon(Icons.folder_outlined, color: Colors.teal),
            )
          : Image.network(
              ApiService.imageUrl(path!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.folder_outlined),
            ),
    ),
  );
}
