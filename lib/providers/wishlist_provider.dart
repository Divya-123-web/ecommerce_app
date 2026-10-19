import 'package:ecommerce_app/data/local_storage.dart';
import 'package:ecommerce_app/data/product.dart';
import 'package:ecommerce_app/data/product_data.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/product_data.dart';
import '../../data/models/product.dart';

class WishlistProvider extends ChangeNotifier {
  // Only product IDs are stored. Loaded from Hive at app start.
  final List<String> _ids = LocalStorage.loadWishlist();

  // Counts only products that still exist in the catalogue
  int get count => items.length;
  bool get isEmpty => items.isEmpty;

  bool isWishlisted(String productId) => _ids.contains(productId);

  // Turns saved IDs back into full products (newest first)
  List<Product> get items {
    final list = <Product>[];
    for (final id in _ids) {
      final product = ProductData.byId(id);
      if (product != null) list.add(product);
    }
    return list;
  }

  // Returns true if the product was added, false if removed
  bool toggle(String productId) {
    final added = !_ids.contains(productId);
    if (added) {
      _ids.insert(0, productId);
    } else {
      _ids.remove(productId);
    }
    notifyListeners();
    LocalStorage.saveWishlist(List<String>.from(_ids));
    return added;
  }
}