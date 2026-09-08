/// Typed access to bundled assets. Never inline an asset path in a widget.
class AppAssets {
  const AppAssets._();

  /// RanjaKen wordmark, white version — for dark surfaces.
  static const String logoWhite = 'assets/images/logo/RanjaKen Logo_Blanc.png';

  /// RanjaKen wordmark, black version — for light surfaces.
  static const String logoBlack = 'assets/images/logo/RanjaKen Logo_Noir.png';

  /// Local mock catalog, consumed by the fake repository (Step 2).
  static const String productsJson = 'assets/data/products.json';
}
