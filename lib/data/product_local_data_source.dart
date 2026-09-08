import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../core/constants/app_assets.dart';
import '../core/errors/app_exception.dart';
import '../models/product.dart';

/// Reads the mock catalog from the asset bundle.
///
/// This is the only place that knows the data comes from a local JSON file.
/// Swapping it for an HTTP client later would not touch the repository API.
class ProductLocalDataSource {
  const ProductLocalDataSource({this.bundle});

  /// Injectable bundle: tests pass a fake, production uses [rootBundle].
  final AssetBundle? bundle;

  AssetBundle get _assets => bundle ?? rootBundle;

  Future<List<Product>> loadProducts() async {
    try {
      final raw = await _assets.loadString(AppAssets.productsJson);
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on AppException {
      rethrow;
    } catch (error) {
      throw DataLoadException('Catalog could not be read ($error).');
    }
  }
}
