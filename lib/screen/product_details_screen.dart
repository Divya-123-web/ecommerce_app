import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/formatters.dart';
import 'package:ecommerce_app/data/product.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/presentation/quantity_selector.dart';
import 'package:ecommerce_app/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quantity_selector.dart';
import '../../widgets/wishlist_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  void _addToCart() {
    context.read<CartProvider>().add(product, quantity: _quantity);

    // Grab these now so the snackbar action still works
    // even if this screen is closed before it is tapped.
    final navigator = Navigator.of(context);
    final tabs = context.read<NavigationProvider>();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_quantity × ${product.name} added to cart'),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () {
              tabs.setIndex(2); // Cart tab
              navigator.popUntil((r) => r.isFirst);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Keeps the layout tidy on tablets and wide screens
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Image + back button + wishlist heart ----------
                Stack(
                  children: [
                    Hero(
                      tag: 'product_${product.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28)),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: AppNetworkImage(url: product.imageUrl),
                        ),
                      ),
                    ),
                    // Back button (top left)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Material(
                            color: Colors.white,
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Wishlist heart (top right)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: WishlistButton(
                              productId: product.id, size: 42),
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------- Details ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 20, color: AppColors.star),
                          const SizedBox(width: 4),
                          Text(product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          Text('In stock',
                              style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(product.description,
                          style: const TextStyle(
                              color: AppColors.textLight, height: 1.5)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quantity',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          QuantitySelector(
                            value: _quantity,
                            onAdd: () => setState(() => _quantity++),
                            onRemove: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ---------- Bottom bar: total + Add to cart ----------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total price',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      Formatters.price(product.price * _quantity),
                      key: ValueKey(_quantity),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PrimaryButton(text: 'Add to cart', onPressed: _addToCart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}