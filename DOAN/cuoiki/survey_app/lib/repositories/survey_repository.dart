import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/survey.dart';
import '../services/api_service.dart';
import '../services/session_helper.dart';

class SurveyRepository {
  static Future<List<Category>> categories() async =>
      (await ApiService.request('GET', 'categories') as List)
          .map((m) => Category.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
  static Future<void> saveCategory(
    int? id,
    String name,
    String description, {
    XFile? image,
    bool removeImage = false,
  }) async {
    final request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(
        '${ApiService.baseUrl}/api/categories${id == null ? '' : '/$id'}',
      ),
    );
    request.headers['Authorization'] = 'Bearer ${await SessionHelper.token}';
    request.fields.addAll({
      'categoryName': name,
      'description': description,
      'removeImage': '$removeImage',
    });
    if (image != null) {
      if (await image.length() > 5242880) throw Exception('Ảnh tối đa 5 MB.');
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    await ApiService.upload(request);
  }

  static Future<void> deleteCategory(int id) async {
    await ApiService.request('DELETE', 'categories/$id');
  }

  static Future<PageData<Survey>> getPage(
    int page,
    int? categoryId,
    String search,
  ) async {
    final query = Uri(
      queryParameters: {
        'page': '$page',
        'pageSize': '10',
        'search': search,
        if (categoryId != null) 'categoryId': '$categoryId',
      },
    ).query;
    final data = await ApiService.request('GET', 'surveys?$query') as Map;
    return PageData(
      (data['items'] as List)
          .map((m) => Survey.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      data['total'] as int,
    );
  }

  static Future<PageData<Survey>> related(int id, int page) async {
    final data = await ApiService.request(
      'GET',
      'surveys/$id/related?page=$page&pageSize=10',
    ) as Map;
    return PageData(
      (data['items'] as List)
          .map((m) => Survey.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      data['total'] as int,
    );
  }

  static Future<Survey> details(int id) async => Survey.fromMap(
    Map<String, dynamic>.from(
      await ApiService.request('GET', 'surveys/$id') as Map,
    ),
  );
  static Future<void> delete(int id) async {
    await ApiService.request('DELETE', 'surveys/$id');
  }

  static Future<void> save(
    int? id,
    int categoryId,
    String title,
    String description,
    List<Question> questions,
    XFile? image,
  ) async {
    final request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse('${ApiService.baseUrl}/api/surveys${id == null ? '' : '/$id'}'),
    );
    request.headers['Authorization'] = 'Bearer ${await SessionHelper.token}';
    request.fields.addAll({
      'categoryId': '$categoryId',
      'title': title,
      'description': description,
      'questionsJson': jsonEncode(questions.map((q) => q.toMap()).toList()),
    });
    if (image != null) {
      if (await image.length() > 5242880) throw Exception('Ảnh tối đa 5 MB.');
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    await ApiService.upload(request);
  }
}
