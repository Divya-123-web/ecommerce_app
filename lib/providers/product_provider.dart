import 'package:ecommerce_app/data/product.dart';
import 'package:ecommerce_app/data/product_data.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/product_data.dart';
import '../../data/models/product.dart';

enum SortOption { relevance, priceLowToHigh, priceHighToLow, topRated }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.topRated:
        return 'Top rated';
    }
  }
}

class ProductProvider extends ChangeNotifier {
  ProductProvider() {
    ProductData.loadFromCache(); // instant, works offline
  }

  bool _loading = false;
  String _query = '';
  String _category = 'All';
  SortOption _sort = SortOption.relevance;
  RangeValues? _priceRange; // null means "no price filter"

  List<Product> get _all => ProductData.products;

  bool get isLoading => _loading;
  bool get hasProducts => _all.isNotEmpty;
  String get query => _query;
  String get category => _category;
  SortOption get sort => _sort;

  // Only categories that actually have products
  List<String> get categories {
    final present = _all.map((p) => p.category).toSet();
    return [
      'All',
      ...ProductData.categories.skip(1).where(present.contains),
    ];
  }

  // Called from the splash screen and from the Retry button
  Future<void> loadCatalogue({bool force = false}) async {
    if (_loading) return;

    // Saved products exist: show them now, refresh quietly in the background
    if (_all.isNotEmpty && !force) {
      ProductData.refresh().then((_) => notifyListeners());
      return;
    }

    _loading = true;
    if (force) notifyListeners();
    await ProductData.refresh(force: force);
    _loading = false;
    notifyListeners();
  }

  // ---------- Price bounds follow the selected category ----------
  List<Product> get _categoryItems => _category == 'All'
      ? _all
      : _all.where((p) => p.category == _category).toList();

  double get minPrice {
    final items = _categoryItems;
    if (items.isEmpty) return 0;
    return items.map((p) => p.price).reduce((a, b) => a < b ? a : b).floorToDouble();
  }

  double get maxPrice {
    final items = _categoryItems;
    final low = minPrice;
    if (items.isEmpty) return low + 1;
    final high =
        items.map((p) => p.price).reduce((a, b) => a > b ? a : b).ceilToDouble();
    return high <= low ? low + 1 : high;
  }

  RangeValues get priceRange {
    final low = minPrice;
    final high = maxPrice;
    final r = _priceRange;
    if (r == null) return RangeValues(low, high);
    return RangeValues(
      r.start.clamp(low, high).toDouble(),
      r.end.clamp(low, high).toDouble(),
    );
  }

  bool get hasActiveFilters =>
      _sort != SortOption.relevance || _priceRange != null;

  String get title {
    if (_query.trim().isNotEmpty) return 'Search results';
    if (_category != 'All') return _category;
    return 'All products';
  }

  // One top-rated product from every category (for the Home screen)
  List<Product> get popular {
    final picks = <Product>[];
    for (final c in categories.skip(1)) {
      final items = _all.where((p) => p.category == c).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      picks.addAll(items.take(1));
    }
    return picks;
  }

  // The filtered + sorted list shown on the list screen
  List<Product> get products {
    // "heels" -> "heel": every word must appear in name, category or description
    final terms = _query
        .toLowerCase()
        .split(' ')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.length > 3 && t.endsWith('s')
            ? t.substring(0, t.length - 1)
            : t)
        .toList();
    final range = priceRange;

    final list = _all.where((p) {
      final matchesCategory = _category == 'All' || p.category == _category;
      final haystack =
          '${p.name} ${p.category} ${p.description}'.toLowerCase();
      final matchesQuery = terms.every(haystack.contains);
      final matchesPrice = p.price >= range.start && p.price <= range.end;
      return matchesCategory && matchesQuery && matchesPrice;
    }).toList();

    switch (_sort) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.relevance:
        break;
    }
    return list;
  }

  // Starts a fresh browsing session (used by Home before opening the list)
  void startBrowsing({String category = 'All', String query = ''}) {
    _category = category;
    _query = query;
    _sort = SortOption.relevance;
    _priceRange = null;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    _priceRange = null; // each category has its own price range
    notifyListeners();
  }

  void applyFilters(SortOption sort, RangeValues range) {
    _sort = sort;
    final isFullRange = range.start <= minPrice && range.end >= maxPrice;
    _priceRange = isFullRange ? null : range;
    notifyListeners();
  }
}