import 'package:ecommerce_app/core/hive_boxes.dart';
import 'package:ecommerce_app/data/cart_item.dart';
import 'package:ecommerce_app/data/order_model.dart';
import 'package:ecommerce_app/data/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_boxes.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class LocalStorage {
  static late Box _users, _session, _cart, _wishlist, _orders, _products;

  static Future<void> init() async {
    _users = await Hive.openBox(HiveBoxes.users);
    _session = await Hive.openBox(HiveBoxes.session);
    _cart = await Hive.openBox(HiveBoxes.cart);
    _wishlist = await Hive.openBox(HiveBoxes.wishlist);
    _orders = await Hive.openBox(HiveBoxes.orders);
    _products = await Hive.openBox(HiveBoxes.products);
  }

  // ---------- Users ----------
  static Future<void> saveUser(UserModel u) => _users.put(u.email, u.toMap());

  static UserModel? findUser(String email) {
    final data = _users.get(email);
    return data == null
        ? null
        : UserModel.fromMap(Map<String, dynamic>.from(data));
  }

  // ---------- Session ----------
  static Future<void> setSession(String email) => _session.put('email', email);
  static Future<void> clearSession() => _session.delete('email');
  static String? get sessionEmail => _session.get('email');

  // ---------- Cart ----------
  static Future<void> saveCart(List<CartItem> items) =>
      _cart.put('items', items.map((i) => i.toMap()).toList());

  static List<CartItem> loadCart() {
    final raw = _cart.get('items', defaultValue: []) as List;
    return raw
        .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------- Wishlist (product IDs only) ----------
  static Future<void> saveWishlist(List<String> ids) =>
      _wishlist.put('ids', ids);

  static List<String> loadWishlist() =>
      List<String>.from(_wishlist.get('ids', defaultValue: []));

  // ---------- Orders ----------
  static Future<void> saveOrders(List<OrderModel> orders) =>
      _orders.put('list', orders.map((o) => o.toMap()).toList());

  static List<OrderModel> loadOrders() {
    final raw = _orders.get('list', defaultValue: []) as List;
    return raw
        .map((e) => OrderModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------- Product catalogue cache (works offline) ----------
  static Future<void> saveProductCache(List<Map<String, dynamic>> items) async {
    await _products.put('list', items);
    await _products.put('savedAt', DateTime.now().toIso8601String());
  }

  static List<Map<String, dynamic>> loadProductCache() {
    final raw = _products.get('list', defaultValue: []) as List;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static bool isProductCacheFresh(Duration maxAge) {
    final saved = _products.get('savedAt') as String?;
    if (saved == null) return false;
    final time = DateTime.tryParse(saved);
    return time != null && DateTime.now().difference(time) < maxAge;
  }
}