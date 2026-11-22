import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trek_bikes_app/category.dart';

class CategoryRepository {
  static String get _url => '${dotenv.env['API_URL']}/api/category';

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => Category.fromMap(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  static Future<int> add(Category obj) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(obj.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return int.tryParse(response.body) ?? 1;
    }
    throw Exception('Failed to add category: ${response.statusCode}');
  }
}
