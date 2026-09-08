import '../core/errors/app_exception.dart';
import '../data/product_local_data_source.dart';
import '../models/product.dart';

/// Contract the UI layer depends on. Implementations decide where the
/// catalog actually comes from.
abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts();

  Future<Product> fetchProductById(String id);
}

/// In-memory repository backed by the bundled JSON catalog.
///
/// [latency] fakes network delay so loading states are visible, and
/// [shouldFail] lets tests and the debug menu exercise the error path.
class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    this.dataSource = const ProductLocalDataSource(),
    this.latency = const Duration(milliseconds: 600),
    this.shouldFail = false,
  });

  final ProductLocalDataSource dataSource;
  final Duration latency;
  final bool shouldFail;

  List<Product>? _cache;

  @override
  Future<List<Product>> fetchProducts() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (shouldFail) {
      throw const DataLoadException(
        'Connection lost while loading the catalog.',
      );
    }
    return _cache ??= await dataSource.loadProducts();
  }

  @override
  Future<Product> fetchProductById(String id) async {
    final products = await fetchProducts();
    final match = products.where((product) => product.id == id);
    if (match.isEmpty) {
      throw NotFoundException('No product matches the id "$id".');
    }
    return match.first;
  }
}
