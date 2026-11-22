import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trek_bikes_app/cart_page.dart';
import 'package:trek_bikes_app/details_page.dart';
import 'package:trek_bikes_app/home_page.dart';
import 'package:trek_bikes_app/login_page.dart';
import 'package:trek_bikes_app/order_page.dart';
import 'package:trek_bikes_app/register_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        "/": (context) => HomePage(title: 'Trek Bikes'),
        "/login": (context) => LoginPage(title: 'Login'),
        "/register": (context) => RegisterPage(title: 'Register'),
        "/profile": (context) => HomePage(title: 'Trek Bikes'),
        "/details": (context) => DetailsPage(title: 'Details'),
        "/cart": (context) => CartPage(title: 'Cart'),
        "/order": (context) => OrderPage(title: 'Order'),
      },
    );
  }
}
