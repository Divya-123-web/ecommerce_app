import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String address;
  final String paymentMethod;
  final String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.address,
    this.paymentMethod = 'Cash on delivery',
    this.status = 'Placed',
  });

  // Total number of units across all items
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Map<String, dynamic> toMap() => {
        'id': id,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'date': date.toIso8601String(),
        'address': address,
        'paymentMethod': paymentMethod,
        'status': status,
      };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
        id: m['id'],
        items: (m['items'] as List)
            .map((i) => CartItem.fromMap(Map<String, dynamic>.from(i)))
            .toList(),
        total: (m['total'] as num).toDouble(),
        date: DateTime.parse(m['date']),
        address: m['address'],
        paymentMethod: (m['paymentMethod'] as String?) ?? 'Cash on delivery',
        status: m['status'],
      );
}