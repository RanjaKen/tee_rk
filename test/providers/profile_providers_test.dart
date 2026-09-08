import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/models/order.dart';
import 'package:tee_rk/models/user_profile.dart';
import 'package:tee_rk/providers/cart_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/providers/profile_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/repositories/profile_repository.dart';

late ProviderContainer container;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          FakeProductRepository(latency: Duration.zero),
        ),
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(latency: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  group('profile', () {
    test('loads the mock account', () async {
      final profile = await container.read(profileProvider.future);

      expect(profile.fullName, 'Ranja Andriamalala');
      expect(profile.email, contains('@'));
      expect(profile.initials, 'RA');
    });

    test('initials cope with one word and padded names', () {
      UserProfile withName(String name) => UserProfile(
        id: 'usr-test',
        fullName: name,
        email: 'test@tee-rk.mg',
        city: 'Antananarivo, MG',
        memberSince: DateTime(2025),
        tier: 'MEMBER',
      );

      expect(withName('Ranja').initials, 'R');
      expect(withName('  ranja   ken  ').initials, 'RK');
      expect(withName('Ranja Ny Aina Ken').initials, 'RK');
    });
  });

  group('orders', () {
    test('history loads newest first', () async {
      final orders = await container.read(ordersProvider.future);

      expect(orders, hasLength(2));
      expect(orders.first.reference, 'RK-2608-0142');
      expect(
        orders.first.placedAt.isAfter(orders.last.placedAt),
        isTrue,
      );
      expect(container.read(ordersCountProvider), 2);
    });

    test('order totals add shipping to the subtotal', () async {
      final orders = await container.read(ordersProvider.future);

      expect(orders.first.subtotal, 414000);
      expect(orders.first.shipping, 20000);
      expect(orders.first.total, 434000);
      expect(orders.first.itemCount, 2);
    });

    test('placeOrder turns the bag into a new order', () async {
      await container.read(ordersProvider.future);
      final repository = container.read(productRepositoryProvider);
      final tee = await repository.fetchProductById('tee-001');

      final cart = container.read(cartProvider.notifier);
      cart.add(tee, 'M', quantity: 2);

      final order = container
          .read(ordersProvider.notifier)
          .placeOrder(
            items: container.read(cartProvider),
            subtotal: container.read(cartSubtotalProvider),
            shipping: container.read(cartShippingProvider),
            placedAt: DateTime(2026, 9, 8),
          );

      expect(order.status, OrderStatus.processing);
      expect(order.lines, hasLength(1));
      expect(order.lines.first.productId, 'tee-001');
      expect(order.lines.first.size, 'M');
      expect(order.lines.first.quantity, 2);
      expect(order.lines.first.unitPrice, 129000);
      expect(order.lines.first.lineTotal, 258000);
      // 258 000 Ar is below the free shipping threshold, so the flat rate
      // is added on top.
      expect(order.shipping, 20000);
      expect(order.total, 278000);

      final orders = container.read(ordersProvider).requireValue;
      expect(orders, hasLength(3));
      expect(orders.first.reference, order.reference);
      expect(container.read(ordersCountProvider), 3);
    });

    test('order lines snapshot the product, not a live reference', () async {
      await container.read(ordersProvider.future);
      final tee = await container
          .read(productRepositoryProvider)
          .fetchProductById('tee-001');

      container.read(cartProvider.notifier).add(tee, 'S');
      final order = container.read(ordersProvider.notifier).placeOrder(
        items: container.read(cartProvider),
        subtotal: container.read(cartSubtotalProvider),
        shipping: container.read(cartShippingProvider),
      );

      expect(order.lines.first.name, tee.name);
      expect(order.lines.first.image, tee.image);
      expect(order.lines.first.unitPrice, tee.price);
    });
  });

  group('settings', () {
    test('defaults and toggles', () {
      expect(container.read(settingsProvider).dropNotifications, isTrue);
      expect(container.read(settingsProvider).newsletter, isFalse);

      container.read(settingsProvider.notifier).setNewsletter(true);
      container.read(settingsProvider.notifier).setDropNotifications(false);
      container.read(settingsProvider.notifier).setPriceAlerts(true);

      final settings = container.read(settingsProvider);
      expect(settings.newsletter, isTrue);
      expect(settings.dropNotifications, isFalse);
      expect(settings.priceAlerts, isTrue);
    });
  });
}
