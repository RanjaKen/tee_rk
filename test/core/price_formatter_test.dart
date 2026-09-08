import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/core/utils/price_formatter.dart';

void main() {
  test('groups thousands and appends the currency', () {
    expect(PriceFormatter.format(129000), '129 000 Ar');
    expect(PriceFormatter.format(845000), '845 000 Ar');
    expect(PriceFormatter.format(0), '0 Ar');
    expect(PriceFormatter.format(999), '999 Ar');
    expect(PriceFormatter.format(1000), '1 000 Ar');
    expect(PriceFormatter.format(12345678), '12 345 678 Ar');
  });

  test('grouped returns digits only', () {
    expect(PriceFormatter.grouped(45000), '45 000');
    expect(PriceFormatter.grouped(-1500), '-1 500');
  });
}
