/// Formats Ariary amounts: `185000` -> `185 000 Ar`.
///
/// Hand rolled on purpose so the project keeps zero extra dependencies.
class PriceFormatter {
  const PriceFormatter._();

  static const String currency = 'Ar';

  static String format(int amount) => '${grouped(amount)} $currency';

  /// Digits only, grouped by thousands: `185000` -> `185 000`.
  static String grouped(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    return negative ? '-$buffer' : buffer.toString();
  }
}
