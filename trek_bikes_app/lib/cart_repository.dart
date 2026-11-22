
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trek_bikes_app/cart.dart';
import 'package:trek_bikes_app/cart_ex.dart';

class CartRepository {
  static Future<int> add(Cart obj, String token) async {
    String url = '${dotenv.env['API_URL']}/api/cart';

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(obj.toMap()),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    }

    throw Exception('Not found data ${response.statusCode}');
  }

  static Future<List<CartEx>> getCarts(String token) async {
    String url = '${dotenv.env['API_URL']}/api/cart';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => CartEx.fromMap(p)).toList();
    }

    throw Exception('Not found data ${response.statusCode}');
  }

  static Future<int> delete(int bikeId, String token) async {
    String url = '${dotenv.env['API_URL']}/api/cart/$bikeId';

    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return 1;
    }

    throw Exception(
      'Delete cart failed ${response.statusCode}',
    );
  }
}
