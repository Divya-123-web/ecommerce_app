import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/presentation/empty_state.dart';
import 'package:ecommerce_app/presentation/product_silver_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/empty_state.dart';
import '../widgets/product_sliver_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

 IconData _categoryIcon(String category) {
    switch (category) {
      case 'Grocery':
        return Icons.local_grocery_store_outlined;
      case 'Bakery':
        return Icons.bakery_dining_outlined;
      case 'Chocolates & Sweets':
        return Icons.cookie_outlined;
      case 'Accessories':
        return Icons.watch_outlined;
      case 'Fashion':
        return Icons.checkroom;
      case 'Beauty & Personal Care':
        return Icons.face_retouching_natural;
      case 'Home & Kitchen':
        return Icons.kitchen_outlined;
      case 'Electronics':
        return Icons.devices_other;
      default:
        return Icons.grid_view_rounded;
    }
  }

  // Opens the product list with a clean category / search state
  void _openList(BuildContext context,
      {String category = 'All', bool focusSearch = false}) {
    context.read<ProductProvider>().startBrowsing(category: category);
    Navigator.pushNamed(context, AppRoutes.productList,
        arguments: focusSearch);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final products = context.watch<ProductProvider>();
    final name = user?.name ?? '';
    final firstName = name.split(' ').first;
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final categories = products.categories.where((c) => c != 'All').toList();
    final topProducts = products.popular;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return CustomScrollView(
              slivers: [
                // ---------- Header ----------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, $firstName 👋',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const Text('Find your favourite products',
                                  style:
                                      TextStyle(color: AppColors.textLight)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(3),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary,
                            child: Text(initial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------- Search bar ----------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      readOnly: true,
                      onTap: () => _openList(context, focusSearch: true),
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------- Banner ----------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 150),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, Color(0xFF9D97FF)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Mega Sale',
                                    style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                const Text('Up to 40% off\non top brands',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () => _openList(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                    ),
                                    child: const Text('Shop now'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.local_offer_rounded,
                              size: 80, color: Colors.white24),
                        ],
                      ),
                    ),
                  ),
                ),

                if (products.hasProducts) ...[
                  // ---------- Categories ----------
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text('Categories',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, i) {
                          final c = categories[i];
                          return GestureDetector(
                            onTap: () => _openList(context, category: c),
                            child: Column(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0D000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(_categoryIcon(c),
                                      color: AppColors.primary),
                                ),
                                const SizedBox(height: 6),
                                Text(c, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ---------- Popular products ----------
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Popular products',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () => _openList(context),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver:
                        ProductSliverGrid(products: topProducts, width: width),
                  ),
                ] else
                  // ---------- No products yet: loading or offline ----------
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: products.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : EmptyState(
                            icon: Icons.wifi_off_rounded,
                            title: 'Could not load products',
                            message:
                                'Check your internet connection and try again.',
                            actionLabel: 'Retry',
                            onAction: () =>
                                products.loadCatalogue(force: true),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}