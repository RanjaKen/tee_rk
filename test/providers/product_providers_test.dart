import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/core/errors/app_exception.dart';
import 'package:tee_rk/models/product.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';

ProviderContainer _container({bool shouldFail = false}) {
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(latency: Duration.zero, shouldFail: shouldFail),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('productsProvider goes from loading to data', () async {
    final container = _container();

    expect(container.read(productsProvider), const AsyncValue<List<Product>>.loading());

    final products = await container.read(productsProvider.future);
    expect(products, hasLength(16));
    expect(container.read(productsProvider).hasValue, isTrue);
  });

  test('productsProvider exposes the error state', () async {
    final container = _container(shouldFail: true);

    await expectLater(
      container.read(productsProvider.future),
      throwsA(isA<DataLoadException>()),
    );

    final state = container.read(productsProvider);
    expect(state.hasError, isTrue);
    expect((state.error! as AppException).message, contains('Connection lost'));
  });

  test('productDetailProvider surfaces NotFoundException', () async {
    final container = _container();

    await expectLater(
      container.read(productDetailProvider('ghost').future),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('productDetailProvider resolves one product', () async {
    final container = _container();

    final product = await container.read(
      productDetailProvider('snk-001').future,
    );
    expect(product.name, 'RK Court Pro 82 Low');
  });

  test('featuredProductsProvider derives the featured slice', () async {
    final container = _container();
    await container.read(productsProvider.future);

    final featured = container.read(featuredProductsProvider).requireValue;
    expect(featured, isNotEmpty);
    expect(featured.every((p) => p.isFeatured), isTrue);
  });
}
