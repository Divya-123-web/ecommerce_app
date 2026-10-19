import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/presentation/empty_state.dart';
import 'package:ecommerce_app/presentation/product_silver_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/empty_state.dart';
import '../widgets/product_sliver_grid.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WishlistProvider>().items;

    return Scaffold(
      appBar: AppBar(title: const Text('My wishlist')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              message: 'Tap the heart on any product to save it here.',
              actionLabel: 'Explore products',
              onAction: () => context.read<NavigationProvider>().setIndex(0),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          '${items.length} saved items',
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 13),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: ProductSliverGrid(
                        products: items,
                        width: constraints.maxWidth,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}