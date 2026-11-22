import 'package:trek_bikes_app/cart.dart';

class CartEx extends Cart {
  final String name;
  final double price;
  final String imageUrl;
  CartEx({
    required super.memberId,
    required super.bikeId,
    required super.quantity,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map = super.toMap();
    map['bikeName'] = name;
    map['price'] = price;
    map['imageUrl'] = imageUrl;
    return map;
  }

  factory CartEx.fromMap(Map<String, dynamic> map) {
    return CartEx(
      memberId: map['memberId'],
      bikeId: map['bikeId'],
      quantity: map['quantity'],
      name: map['bikeName'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }
}
