import '../data/favorites_local_data_source.dart';

/// Contract for reading and storing the favorite product ids.
abstract interface class FavoritesRepository {
  Future<Set<String>> load();

  Future<void> save(Set<String> ids);
}

/// Device local implementation, backed by shared_preferences.
class LocalFavoritesRepository implements FavoritesRepository {
  const LocalFavoritesRepository({
    this.dataSource = const FavoritesLocalDataSource(),
  });

  final FavoritesLocalDataSource dataSource;

  @override
  Future<Set<String>> load() => dataSource.read();

  @override
  Future<void> save(Set<String> ids) => dataSource.write(ids);
}

/// Volatile implementation used by tests and previews.
class InMemoryFavoritesRepository implements FavoritesRepository {
  InMemoryFavoritesRepository({Set<String>? initial, this.failOnSave = false})
    : _ids = {...?initial};

  Set<String> _ids;

  /// Lets tests exercise the revert path of the notifier.
  final bool failOnSave;

  @override
  Future<Set<String>> load() async => {..._ids};

  @override
  Future<void> save(Set<String> ids) async {
    if (failOnSave) throw StateError('storage unavailable');
    _ids = {...ids};
  }
}
