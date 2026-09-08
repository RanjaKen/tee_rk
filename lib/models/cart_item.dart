import 'product.dart';

/// One line in the bag: a product in a specific size.
///
/// The same product in two sizes is two lines, which is why [key]
/// combines both.
class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final String size;
  final int quantity;

  /// Stable identity of the line.
  String get key => cartKey(product.id, size);

  /// Price of the line in Ariary.
  int get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    size: size,
    quantity: quantity ?? this.quantity,
  );

  static String cartKey(String productId, String size) => '$productId::$size';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.key == key &&
          other.quantity == quantity);

  @override
  int get hashCode => Object.hash(key, quantity);

  @override
  String toString() => 'CartItem($key x$quantity)';
}
