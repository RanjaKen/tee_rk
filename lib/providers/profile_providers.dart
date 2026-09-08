import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Injection point for the account source.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => MockProfileRepository(),
);

/// The mock account.
class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() {
    return ref.watch(profileRepositoryProvider).fetchProfile();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).fetchProfile(),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
  retry: _noRetry,
);

/// Order history, newest first.
///
/// Seeded from the repository, then appended to by checkout. Orders are
/// session scoped: this build has no backend to store them.
class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final orders = await ref.watch(profileRepositoryProvider).fetchOrders();
    return [...orders]..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  }

  /// Turns the current bag into an order and puts it at the top.
  Order placeOrder({
    required List<CartItem> items,
    required int subtotal,
    required int shipping,
    DateTime? placedAt,
  }) {
    final now = placedAt ?? DateTime.now();
    final order = Order(
      reference: _reference(now),
      placedAt: now,
      subtotal: subtotal,
      shipping: shipping,
      status: OrderStatus.processing,
      lines: [
        for (final item in items)
          OrderLine(
            productId: item.product.id,
            name: item.product.name,
            image: item.product.image,
            size: item.size,
            quantity: item.quantity,
            unitPrice: item.product.price,
          ),
      ],
    );

    state = AsyncData([order, ...state.value ?? const <Order>[]]);
    return order;
  }

  String _reference(DateTime date) {
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final serial = ((state.value?.length ?? 0) + 1) * 7 + date.day;
    return 'RK-$yy$mm-${serial.toString().padLeft(4, '0')}';
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
  retry: _noRetry,
);

Duration? _noRetry(int retryCount, Object error) => null;

final ordersCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider).value?.length ?? 0;
});

/// Preferences shown in the settings section.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setDropNotifications(bool value) =>
      state = state.copyWith(dropNotifications: value);

  void setNewsletter(bool value) => state = state.copyWith(newsletter: value);

  void setPriceAlerts(bool value) => state = state.copyWith(priceAlerts: value);
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
