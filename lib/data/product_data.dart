import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'local_storage.dart';

class ProductData {
  ProductData._();

  static const _endpoint = 'https://dummyjson.com/products?limit=0'
      '&select=title,description,category,price,discountPercentage,rating,'
      'stock,brand,reviews,returnPolicy,warrantyInformation,thumbnail';

  static const _cacheMaxAge = Duration(hours: 12);
  static const _usdToInr = 83.0;

  // The order shown in the app. Bakery and Chocolates & Sweets stay hidden
  // until they have products (added in a later step).
  static const categories = [
    'All',
    'Grocery',
    'Bakery',
    'Chocolates & Sweets',
    'Accessories',
    'Fashion',
    'Beauty & Personal Care',
    'Home & Kitchen',
    'Electronics',
  ];

  // API category -> (our category, our subcategory).
  // Anything not listed (vehicles, sports...) is skipped.
  static const Map<String, (String, String)> _categoryMap = {
    'groceries': ('Grocery', 'Groceries'), // refined by _grocerySub
    'sunglasses': ('Accessories', 'Sunglasses'),
    'mens-watches': ('Accessories', 'Watches'),
    'womens-watches': ('Accessories', 'Watches'),
    'womens-bags': ('Accessories', 'Handbags'),
    'womens-jewellery': ('Accessories', 'Jewellery'),
    'mens-shirts': ('Fashion', "Men's Clothing"),
    'tops': ('Fashion', "Women's Clothing"),
    'womens-dresses': ('Fashion', 'Dresses'),
    'mens-shoes': ('Fashion', 'Footwear'),
    'womens-shoes': ('Fashion', 'Footwear'),
    'beauty': ('Beauty & Personal Care', 'Beauty Products'),
    'skin-care': ('Beauty & Personal Care', 'Skincare'),
    'fragrances': ('Beauty & Personal Care', 'Fragrances'),
    'kitchen-accessories': ('Home & Kitchen', 'Kitchen Accessories'),
    'home-decoration': ('Home & Kitchen', 'Home Decor'),
    'furniture': ('Home & Kitchen', 'Furniture'),
    'smartphones': ('Electronics', 'Smartphones'),
    'laptops': ('Electronics', 'Laptops'),
    'tablets': ('Electronics', 'Tablets'),
    'mobile-accessories': ('Electronics', 'Mobile Accessories'),
  };

  // The in-memory catalogue used by the whole app
  static List<Product> products = [];

  static Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  // Instant and offline: reads the saved copy from Hive
  static void loadFromCache() {
    final saved = LocalStorage.loadProductCache();
    // A copy saved by an older app version has no 'mrp': ignore it
    // so the catalogue is downloaded again in the new format.
    if (saved.isNotEmpty && !saved.first.containsKey('mrp')) {
      products = [];
      return;
    }
    products = saved.map((m) => Product.fromMap(m)).toList();
  }

  // Downloads a fresh catalogue. Returns true if products are available.
  static Future<bool> refresh({bool force = false}) async {
    if (!force &&
        products.isNotEmpty &&
        LocalStorage.isProductCacheFresh(_cacheMaxAge)) {
      return true;
    }

    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return products.isNotEmpty;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final fetched = <Product>[];
      for (final item in data['products'] as List) {
        final json = item as Map<String, dynamic>;
        final mapped = _categoryMap[json['category']];
        if (mapped == null) continue;

        final (top, sub) = mapped;
        final title = json['title'] as String;
        fetched.add(_fromApi(json, top, top == 'Grocery' ? _grocerySub(title) : sub));
      }
      if (fetched.isEmpty) return products.isNotEmpty;

      // Group by our category order
      final grouped = <Product>[];
      for (final c in categories.skip(1)) {
        grouped.addAll(fetched.where((p) => p.category == c));
      }

      products = grouped;
      await LocalStorage.saveProductCache(
          grouped.map((p) => p.toMap()).toList());
      return true;
    } catch (_) {
      // No internet or a bad response: keep whatever we already have
      return products.isNotEmpty;
    }
  }

  static Product _fromApi(
      Map<String, dynamic> json, String category, String subCategory) {
    final mrp = _toRupees((json['price'] as num).toDouble());
    final percent = ((json['discountPercentage'] as num?)?.toDouble() ?? 0)
        .clamp(0, 90)
        .toDouble();
    final selling =
        percent >= 1 ? (mrp * (1 - percent / 100)).roundToDouble() : mrp;

    final offers = <String>[];
    if (percent >= 1) offers.add('${percent.round()}% off on MRP');
    final returns = json['returnPolicy'] as String?;
    if (returns != null && returns.isNotEmpty) offers.add(returns);
    final warranty = json['warrantyInformation'] as String?;
    if (warranty != null &&
        warranty.isNotEmpty &&
        !warranty.toLowerCase().contains('no warranty')) {
      offers.add(warranty);
    }
    offers.add('Free delivery above ₹5,000');

    return Product(
      id: 'd${json['id']}',
      name: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      price: selling,
      mrp: mrp,
      imageUrl: json['thumbnail'] as String,
      category: category,
      subCategory: subCategory,
      brand: (json['brand'] as String?) ?? '',
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviews'] as List?)?.length ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      offers: offers,
    );
  }

  // The grocery data is one big list, so we sort it by keywords in the name
  static String _grocerySub(String title) {
    final t = title.toLowerCase();
    bool has(List<String> words) => words.any(t.contains);

    if (has(['apple', 'kiwi', 'lemon', 'mulberry', 'strawberry', 'cucumber',
        'pepper', 'potato', 'onion', 'tomato', 'banana', 'orange', 'mango',
        'grape', 'carrot', 'eggplant'])) {
      return 'Fruits & Vegetables';
    }
    if (has(['milk', 'cheese', 'butter', 'yogurt', 'egg', 'cream'])) {
      return 'Dairy & Eggs';
    }
    if (has(['juice', 'drink', 'water', 'coffee', 'tea', 'soda', 'cola'])) {
      return 'Beverages';
    }
    if (has(['rice', 'wheat', 'flour', 'grain', 'oat', 'pasta', 'noodle'])) {
      return 'Rice & Grains';
    }
    if (has(['oil', 'honey', 'sugar', 'salt', 'spice', 'masala', 'sauce'])) {
      return 'Cooking Essentials';
    }
    if (has(['beef', 'chicken', 'fish', 'meat', 'mutton'])) {
      return 'Meat & Seafood';
    }
    if (has(['cat food', 'dog food', 'pet'])) return 'Pet Care';
    if (has(['tissue', 'paper', 'soap', 'detergent', 'cleaner'])) {
      return 'Household Essentials';
    }
    return 'More Groceries';
  }

  // $9.99 -> ₹829 (rounded to a price ending in 9)
  static double _toRupees(double usd) {
    final rounded = ((usd * _usdToInr) / 10).round() * 10 - 1;
    return rounded < 49 ? 49.0 : rounded.toDouble();
  }
}