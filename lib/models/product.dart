import 'product_category.dart';

/// A catalog item (tee, sneaker, jersey or accessory).
///
/// Immutable value object. Parsing lives here so neither the repository
/// nor the UI has to know the JSON shape.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.isNew,
    required this.isFeatured,
    required this.releasedAt,
  });

  final String id;
  final String name;
  final String brand;
  final ProductCategory category;
  final String description;

  /// Price in Ariary (MGA). Integer: the currency has no practical decimals.
  final int price;

  /// Asset path of the product shot.
  final String image;

  /// Available sizes, e.g. `['S', 'M', 'L']` or `['ONE SIZE']`.
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isNew;
  final bool isFeatured;
  final DateTime releasedAt;

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: ProductCategory.fromJson(json['category'] as String),
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      image: json['image'] as String,
      sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      colors: (json['colors'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      isNew: json['isNew'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      releasedAt: DateTime.parse(json['releasedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product($id, $name)';
}
