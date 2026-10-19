import 'package:ecommerce_app/core/responsive.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/product.dart';
import 'fade_slide_in.dart';
import 'product_card.dart';

class ProductSliverGrid extends StatelessWidget {
  final List<Product> products;
  final double width;

  const ProductSliverGrid({
    super.key,
    required this.products,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(width),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: Responsive.gridAspectRatio(width),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final product = products[i];
          return FadeSlideIn(
            index: i,
            child: ProductCard(
              product: product,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.productDetails,
                arguments: product,
              ),
            ),
          );
        },
        childCount: products.length,
      ),
    );
  }
}