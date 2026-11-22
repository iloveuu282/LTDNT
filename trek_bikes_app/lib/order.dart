class Order {
  final int? id;
  final String? memberId;
  final int statusId;
  final String? statusName;

  Order({required this.id, required this.memberId, required this.statusId, required this.statusName});

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['orderId'],
      memberId: map['memberId'],
      statusId: map['statusId'],
      statusName: map.containsKey('statusName') ? map['statusName'] : null,
    );
  }

  Map<String, Object?> toMap() {
    return {'orderId': id ?? 0, 'memberId': memberId, 'statusId': statusId};
  }
}
