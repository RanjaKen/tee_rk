/// Catalog categories.
///
/// The JSON value is stored in the mock data; [label] is what the UI shows.
enum ProductCategory {
  tshirts('tshirts', 'T-SHIRTS'),
  sneakers('sneakers', 'SNEAKERS'),
  jerseys('jerseys', 'JERSEYS'),
  accessories('accessories', 'ACCESSORIES');

  const ProductCategory(this.json, this.label);

  /// Value used in `products.json`.
  final String json;

  /// Uppercase display label.
  final String label;

  static ProductCategory fromJson(String value) {
    return ProductCategory.values.firstWhere(
      (category) => category.json == value,
      orElse: () => throw FormatException('Unknown product category: $value'),
    );
  }
}
