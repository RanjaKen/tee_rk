import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_providers.dart';

/// Size chosen by the user, per product id.
///
/// Riverpod 3 plain [Notifier] cannot read a family argument, so the
/// selections live in one map and [selectedSizeProvider] exposes the
/// per-product read API.
class SelectedSizesNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void select(String productId, String size) {
    state = {...state, productId: size};
  }

  void clear(String productId) {
    state = {...state}..remove(productId);
  }
}

final selectedSizesProvider =
    NotifierProvider<SelectedSizesNotifier, Map<String, String>>(
      SelectedSizesNotifier.new,
    );

/// Effective size for a product: the explicit choice, or the only size
/// available when the product ships in a single size.
final selectedSizeProvider = Provider.family<String?, String>((ref, productId) {
  final explicit = ref.watch(selectedSizesProvider)[productId];
  if (explicit != null) return explicit;

  final product = ref.watch(productDetailProvider(productId)).value;
  if (product != null && product.sizes.length == 1) return product.sizes.first;
  return null;
});
