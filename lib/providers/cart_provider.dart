import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// The shopping bag.
///
/// Holds an immutable list of [CartItem]; every mutation replaces the
/// list so Riverpod can diff it. All quantity rules (stock ceiling, line
/// cap, removal at zero) live here rather than in the UI.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Adds [quantity] of [product] in [size], merging with an existing line.
  void add(Product product, String size, {int quantity = 1}) {
    if (!product.inStock || quantity < 1) return;

    final key = CartItem.cartKey(product.id, size);
    final index = state.indexWhere((item) => item.key == key);

    if (index == -1) {
      state = [
        ...state,
        CartItem(
          product: product,
          size: size,
          quantity: _clamp(quantity, product),
        ),
      ];
      return;
    }

    final existing = state[index];
    _replace(index, existing.copyWith(
      quantity: _clamp(existing.quantity + quantity, product),
    ));
  }

  void increment(String key) => _shift(key, 1);

  /// Decreases a line, removing it when it would reach zero.
  void decrement(String key) => _shift(key, -1);

  void remove(String key) {
    state = state.where((item) => item.key != key).toList();
  }

  void clear() => state = const [];

  /// Quantity currently in the bag for a product/size pair.
  int quantityOf(String productId, String size) {
    final key = CartItem.cartKey(productId, size);
    for (final item in state) {
      if (item.key == key) return item.quantity;
    }
    return 0;
  }

  void _shift(String key, int delta) {
    final index = state.indexWhere((item) => item.key == key);
    if (index == -1) return;

    final item = state[index];
    final next = item.quantity + delta;
    if (next < 1) {
      remove(key);
      return;
    }
    _replace(index, item.copyWith(quantity: _clamp(next, item.product)));
  }

  void _replace(int index, CartItem item) {
    final next = [...state];
    next[index] = item;
    state = next;
  }

  int _clamp(int quantity, Product product) {
    final ceiling = product.stock < AppConfig.maxQuantityPerLine
        ? product.stock
        : AppConfig.maxQuantityPerLine;
    return quantity > ceiling ? ceiling : quantity;
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// Total number of units in the bag (drives the nav badge).
final cartCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Sum of the lines, before shipping.
final cartSubtotalProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.lineTotal);
});

/// Shipping fee: free above the threshold, flat rate otherwise.
final cartShippingProvider = Provider<int>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal == 0 || subtotal >= AppConfig.freeShippingThreshold) return 0;
  return AppConfig.shippingFlatRate;
});

/// Amount actually due.
final cartTotalProvider = Provider<int>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartShippingProvider);
});
