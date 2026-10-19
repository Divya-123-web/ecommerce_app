import 'package:ecommerce_app/data/cart_item.dart';
import 'package:ecommerce_app/data/local_storage.dart';
import 'package:ecommerce_app/data/product.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  static const double freeShippingAbove = 5000;
  static const double shippingFee = 99;

  // Loaded from Hive when the app starts
  final List<CartItem> _items = LocalStorage.loadCart();

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  // Total number of units (used for the badge)
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.total);

  double get shipping =>
      (subtotal == 0 || subtotal >= freeShippingAbove) ? 0 : shippingFee;

  double get total => subtotal + shipping;

  double get amountForFreeShipping =>
      subtotal >= freeShippingAbove ? 0 : freeShippingAbove - subtotal;

  int _indexOf(String productId) =>
      _items.indexWhere((i) => i.product.id == productId);

  void add(Product product, {int quantity = 1}) {
    final index = _indexOf(product.id);
    if (index >= 0) {
      _items[index].quantity += quantity; // already in cart: just add more
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    _save();
  }

  void increment(String productId) {
    final index = _indexOf(productId);
    if (index >= 0) {
      _items[index].quantity++;
      _save();
    }
  }

  // Never goes below 1. Use remove() to delete an item.
  void decrement(String productId) {
    final index = _indexOf(productId);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity--;
      _save();
    }
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _save();
  }

  void clear() {
    _items.clear();
    _save();
  }

  // Update the screen, then save to Hive
  void _save() {
    notifyListeners();
    LocalStorage.saveCart(_items);
  }
}