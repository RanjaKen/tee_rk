/// Ordering applied to the catalog.
enum SortOption {
  newest('NEWEST'),
  priceLowHigh('PRICE: LOW TO HIGH'),
  priceHighLow('PRICE: HIGH TO LOW'),
  nameAZ('NAME: A TO Z'),
  nameZA('NAME: Z TO A');

  const SortOption(this.label);

  final String label;
}
