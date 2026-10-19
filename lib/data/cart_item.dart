import 'package:ecommerce_app/models/product.dart';

import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;

  Map<String, dynamic> toMap() =>
      {'product': product.toMap(), 'quantity': quantity};

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        product: Product.fromMap(Map<String, dynamic>.from(m['product'])),
        quantity: m['quantity'],
      );
}