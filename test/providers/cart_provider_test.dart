import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/core/constants/app_config.dart';
import 'package:tee_rk/models/product.dart';
import 'package:tee_rk/providers/cart_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';

late ProviderContainer container;

CartNotifier get cart => container.read(cartProvider.notifier);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Product tee; // 129 000 Ar, stock 42
  late Product socks; // 45 000 Ar, stock 120
  late Product duffle; // 320 000 Ar, stock 12
  late Product jersey; // 285 000 Ar, stock 14
  late Product soldOut; // stock 0

  setUp(() async {
    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          FakeProductRepository(latency: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(productRepositoryProvider);
    tee = await repository.fetchProductById('tee-001');
    socks = await repository.fetchProductById('acc-003');
    duffle = await repository.fetchProductById('acc-004');
    jersey = await repository.fetchProductById('jrs-001');
    soldOut = await repository.fetchProductById('tee-004');
  });

  test('starts empty', () {
    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartCountProvider), 0);
    expect(container.read(cartTotalProvider), 0);
  });

  test('adds a product and computes the line total', () {
    cart.add(tee, 'M');

    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(cartCountProvider), 1);
    expect(container.read(cartSubtotalProvider), 129000);
    expect(container.read(cartProvider).first.size, 'M');
  });

  test('same product in the same size merges into one line', () {
    cart.add(tee, 'M');
    cart.add(tee, 'M', quantity: 2);

    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(cartProvider).first.quantity, 3);
    expect(container.read(cartCountProvider), 3);
    expect(container.read(cartSubtotalProvider), 129000 * 3);
  });

  test('same product in another size is a separate line', () {
    cart.add(tee, 'M');
    cart.add(tee, 'L');

    expect(container.read(cartProvider), hasLength(2));
    expect(container.read(cartCountProvider), 2);
  });

  test('increment and decrement adjust the quantity', () {
    cart.add(tee, 'M');
    final key = container.read(cartProvider).first.key;

    cart.increment(key);
    expect(container.read(cartCountProvider), 2);

    cart.decrement(key);
    expect(container.read(cartCountProvider), 1);
  });

  test('decrementing the last unit removes the line', () {
    cart.add(tee, 'M');
    cart.decrement(container.read(cartProvider).first.key);

    expect(container.read(cartProvider), isEmpty);
  });

  test('quantity is capped by the per line maximum', () {
    cart.add(socks, 'M', quantity: 50);

    expect(
      container.read(cartProvider).first.quantity,
      AppConfig.maxQuantityPerLine,
    );
  });

  test('quantity is capped by the remaining stock', () {
    cart.add(duffle, 'ONE SIZE', quantity: 50); // stock 12, cap 10
    expect(container.read(cartProvider).first.quantity, 10);
  });

  test('sold out products are rejected', () {
    cart.add(soldOut, 'M');
    expect(container.read(cartProvider), isEmpty);
  });

  test('remove and clear empty the bag', () {
    cart.add(tee, 'M');
    cart.add(socks, 'L');

    cart.remove(container.read(cartProvider).first.key);
    expect(container.read(cartProvider), hasLength(1));

    cart.clear();
    expect(container.read(cartProvider), isEmpty);
  });

  test('quantityOf reports what is in the bag', () {
    cart.add(tee, 'M', quantity: 2);

    expect(cart.quantityOf('tee-001', 'M'), 2);
    expect(cart.quantityOf('tee-001', 'L'), 0);
  });

  group('shipping', () {
    test('flat rate below the free shipping threshold', () {
      cart.add(socks, 'M'); // 45 000 Ar

      expect(container.read(cartSubtotalProvider), 45000);
      expect(container.read(cartShippingProvider), AppConfig.shippingFlatRate);
      expect(
        container.read(cartTotalProvider),
        45000 + AppConfig.shippingFlatRate,
      );
    });

    test('free at or above the threshold', () {
      cart.add(jersey, 'L', quantity: 2); // 570 000 Ar

      expect(container.read(cartSubtotalProvider), 570000);
      expect(container.read(cartShippingProvider), 0);
      expect(container.read(cartTotalProvider), 570000);
    });

    test('an empty bag is never charged shipping', () {
      expect(container.read(cartShippingProvider), 0);
      expect(container.read(cartTotalProvider), 0);
    });
  });
}
