class Cart {
  final String? memberId;
  final int bikeId;
  final int quantity;

  Cart({required this.memberId, required this.bikeId, required this.quantity});

  Map<String, Object?> toMap() {
    return {'memberId': memberId, 'bikeId': bikeId, 'quantity': quantity};
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      memberId: map['memberId'],
      bikeId: map['bikeId'],
      quantity: map['quantity'],
    );
  }
}