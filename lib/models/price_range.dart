/// Inclusive price window in Ariary.
class PriceRange {
  const PriceRange({required this.min, required this.max});

  final int min;
  final int max;

  bool contains(int price) => price >= min && price <= max;

  /// True when the window still covers everything between [bounds].
  bool coversAll(PriceRange bounds) => min <= bounds.min && max >= bounds.max;

  PriceRange copyWith({int? min, int? max}) =>
      PriceRange(min: min ?? this.min, max: max ?? this.max);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceRange && other.min == min && other.max == max);

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'PriceRange($min..$max)';
}
