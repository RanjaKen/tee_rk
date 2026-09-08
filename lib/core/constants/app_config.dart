/// Shop level rules kept out of the widgets.
class AppConfig {
  const AppConfig._();

  /// Orders at or above this amount (Ariary) ship for free.
  static const int freeShippingThreshold = 500000;

  /// Flat shipping fee in Ariary below the threshold.
  static const int shippingFlatRate = 20000;

  /// Hard cap per line, whatever the stock level.
  static const int maxQuantityPerLine = 10;
}
