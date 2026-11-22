import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trek_bikes_app/order.dart';

class OrderRepository {
  static Future<List<Order>> getOrders(String token) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/order');
    var response = await http.get(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Order.fromMap(p)).toList();
    }
    throw Exception('not found data');
  }

  static Future<int> save(Order obj, String token) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/order');
    var response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(obj.toMap()),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -2;
  }

  static Future<int> update(Order obj, String token) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/order/updatestatus');
    var response = await http.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(obj.toMap()),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -2;
  }
}
