/// Where an order currently is.
enum OrderStatus {
  processing('PROCESSING'),
  shipped('SHIPPED'),
  delivered('DELIVERED');

  const OrderStatus(this.label);

  final String label;
}

/// A snapshot of one bag line at the moment the order was placed.
///
/// Prices and names are copied on purpose: a later catalog change must
/// not rewrite order history.
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.image,
    required this.size,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String name;
  final String image;
  final String size;
  final int quantity;
  final int unitPrice;

  int get lineTotal => unitPrice * quantity;
}

/// A placed order.
class Order {
  const Order({
    required this.reference,
    required this.placedAt,
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.status,
  });

  final String reference;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final int subtotal;
  final int shipping;
  final OrderStatus status;

  int get total => subtotal + shipping;

  int get itemCount =>
      lines.fold<int>(0, (sum, line) => sum + line.quantity);
}
