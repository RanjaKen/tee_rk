import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/app_exception.dart';

/// Persists favorite product ids on the device.
///
/// Only this class knows the storage key and that the backend is
/// shared_preferences.
class FavoritesLocalDataSource {
  const FavoritesLocalDataSource();

  static const String storageKey = 'tee_rk.favorites.v1';

  Future<Set<String>> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(storageKey) ?? const <String>[]).toSet();
    } catch (error) {
      throw DataLoadException('Saved items could not be read ($error).');
    }
  }

  Future<void> write(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(storageKey, ids.toList(growable: false));
    } catch (error) {
      throw DataLoadException('Saved items could not be stored ($error).');
    }
  }
}
