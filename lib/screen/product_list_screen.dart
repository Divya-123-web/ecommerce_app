import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/presentation/category_chip.dart';
import 'package:ecommerce_app/presentation/empty_state.dart';
import 'package:ecommerce_app/widgets/filter_sheet.dart';
import 'package:ecommerce_app/presentation/product_provider.dart';
import 'package:ecommerce_app/presentation/product_silver_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_sheet.dart';
import '../widgets/product_sliver_grid.dart';

class ProductListScreen extends StatefulWidget {
  final bool focusSearch;

  const ProductListScreen({super.key, this.focusSearch = false});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<ProductProvider>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final items = provider.products;

    return Scaffold(
      appBar: AppBar(title: Text(provider.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return CustomScrollView(
            slivers: [
              // ---------- Search + filter button ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _search,
                          autofocus: widget.focusSearch,
                          onChanged: provider.setQuery,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search products',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _search.clear();
                                      provider.setQuery('');
                                    },
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _openFilters,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Badge(
                            isLabelVisible: provider.hasActiveFilters,
                            smallSize: 9,
                            child: const Icon(Icons.tune_rounded,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Category chips ----------
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: provider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = provider.categories[i];
                      return CategoryChip(
                        label: c,
                        selected: provider.category == c,
                        onTap: () => provider.setCategory(c),
                      );
                    },
                  ),
                ),
              ),

              // ---------- Result count ----------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '${items.length} products found',
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 13),
                  ),
                ),
              ),

              // ---------- Results ----------
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No products found',
                    message: 'Try a different keyword or clear the filters.',
                    actionLabel: 'Clear filters',
                    onAction: () {
                      _search.clear();
                      provider.startBrowsing();
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: ProductSliverGrid(products: items, width: width),
                ),
            ],
          );
        },
      ),
    );
  }
}