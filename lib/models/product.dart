class Product {
  final String id;
  final String name;
  final String description;
  final double price; // selling price after discount (used by cart and orders)
  final double mrp; // original price before discount
  final String imageUrl;
  final String category; // top-level group, e.g. Fashion
  final String subCategory; // e.g. Footwear
  final String brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> offers;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    double? mrp,
    this.subCategory = '',
    this.brand = '',
    this.reviewCount = 0,
    this.stock = 25,
    this.offers = const [],
  }) : mrp = mrp ?? price;

  int get discountPercent =>
      mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;

  bool get hasDiscount => discountPercent > 0;
  bool get inStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'mrp': mrp,
        'imageUrl': imageUrl,
        'category': category,
        'subCategory': subCategory,
        'brand': brand,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'offers': offers,
      };

  // Missing fields get defaults, so products saved by older versions still load
  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        description: (m['description'] as String?) ?? '',
        price: (m['price'] as num).toDouble(),
        mrp: (m['mrp'] as num?)?.toDouble(),
        imageUrl: m['imageUrl'] as String,
        category: m['category'] as String,
        subCategory: (m['subCategory'] as String?) ?? '',
        brand: (m['brand'] as String?) ?? '',
        rating: (m['rating'] as num).toDouble(),
        reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
        stock: (m['stock'] as num?)?.toInt() ?? 25,
        offers: List<String>.from((m['offers'] as List?) ?? const []),
      );
}