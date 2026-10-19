import 'package:ecommerce_app/data/cart_item.dart';
import 'package:ecommerce_app/data/local_storage.dart';
import 'package:ecommerce_app/data/order_model.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  // Loaded from Hive at app start (newest first)
  final List<OrderModel> _orders = LocalStorage.loadOrders();

  List<OrderModel> get orders => List.unmodifiable(_orders);
  int get count => _orders.length;

  OrderModel placeOrder({
    required List<CartItem> items,
    required double total,
    required String address,
    required String paymentMethod,
  }) {
    final order = OrderModel(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      // Copy the items so clearing the cart later can't affect this order
      items: items
          .map((i) => CartItem(product: i.product, quantity: i.quantity))
          .toList(),
      total: total,
      date: DateTime.now(),
      address: address,
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, order);
    notifyListeners();
    LocalStorage.saveOrders(_orders);
    return order;
  }
}