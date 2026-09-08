import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/core/errors/app_exception.dart';
import 'package:tee_rk/models/product_category.dart';
import 'package:tee_rk/repositories/product_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = FakeProductRepository(latency: Duration.zero);

  test('loads and parses the bundled catalog', () async {
    final products = await repository.fetchProducts();

    expect(products, hasLength(16));
    expect(products.map((p) => p.id).toSet(), hasLength(16));
    expect(
      products.map((p) => p.category).toSet(),
      containsAll(ProductCategory.values),
    );
    expect(products.every((p) => p.price > 0), isTrue);
    expect(products.every((p) => p.sizes.isNotEmpty), isTrue);
    expect(products.every((p) => p.image.startsWith('assets/')), isTrue);
  });

  test('fetchProductById returns the matching product', () async {
    final product = await repository.fetchProductById('tee-001');

    expect(product.name, 'RKN-ATHL. Urban Canvas Tee');
    expect(product.price, 129000);
    expect(product.category, ProductCategory.tshirts);
    expect(product.inStock, isTrue);
  });

  test('fetchProductById throws NotFoundException for an unknown id', () {
    expect(
      () => repository.fetchProductById('nope'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('shouldFail surfaces a DataLoadException', () {
    final failing = FakeProductRepository(
      latency: Duration.zero,
      shouldFail: true,
    );

    expect(failing.fetchProducts(), throwsA(isA<DataLoadException>()));
  });
}
