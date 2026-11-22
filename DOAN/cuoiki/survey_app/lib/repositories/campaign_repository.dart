import 'dart:math';

import '../models/survey.dart';
import '../services/api_service.dart';

class CampaignRepository {
  static String newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static Future<List<PlanItem>> plan() async =>
      (await ApiService.request('GET', 'plan') as List)
          .map((m) => PlanItem.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
  static Future<void> putPlan(int id, int target) async {
    await ApiService.request('PUT', 'plan/$id', {'targetCount': target});
  }

  static Future<void> removePlan(int id) async {
    await ApiService.request('DELETE', 'plan/$id');
  }

  static Future<int> checkout(String title, String requestId) async =>
      (await ApiService.request('POST', 'plan/checkout', {
            'title': title,
            'requestId': requestId,
          }) as Map)['campaignId']
          as int;
  static Future<PageData<Campaign>> getPage(
    int page,
    bool open, {
    String search = '',
    String? fromDate,
    String? toDate,
  }) async {
    final query = Uri(
      queryParameters: {
        'page': '$page',
        'pageSize': '10',
        'open': '$open',
        'search': search,
        'fromDate': ?fromDate,
        'toDate': ?toDate,
      },
    ).query;
    final data = await ApiService.request('GET', 'campaigns?$query') as Map;
    return PageData(
      (data['items'] as List)
          .map((m) => Campaign.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      data['total'] as int,
    );
  }

  static Future<Map<String, dynamic>> details(int id) async =>
      Map<String, dynamic>.from(
        await ApiService.request('GET', 'campaigns/$id') as Map,
      );
  static Future<void> status(int id, String status) async {
    await ApiService.request('PUT', 'campaigns/$id/status', {'status': status});
  }

  static Future<void> submit(
    int campaignId,
    int itemId,
    String submissionId,
    Map<String, dynamic> answers,
  ) async {
    await ApiService.request(
      'POST',
      'campaigns/$campaignId/items/$itemId/responses',
      {'submissionId': submissionId, 'answers': answers},
    );
  }

  static Future<Map<String, dynamic>> results(
    int campaignId,
    int itemId,
  ) async => Map<String, dynamic>.from(
    await ApiService.request(
      'GET',
      'campaigns/$campaignId/items/$itemId/results',
    ) as Map,
  );
}
