import 'package:shared_preferences/shared_preferences.dart';

class Persistence {
  static bool init_called = false;
  static Future<SharedPreferencesWithCache> _loadingStore = Future.error(Exception('Uninitialized'));
  static SharedPreferencesWithCache? _store = null;
  static SharedPreferencesWithCache get store => _store!;

  static void init() {
    if (!init_called) {
      init_called = true;
      _loadingStore = SharedPreferencesWithCache.create(
        cacheOptions: SharedPreferencesWithCacheOptions(),
      );
    }
  }

  static Future<bool> isLoaded() async {
    if(_store != null) return true;
    _store = await _loadingStore;
    return true;
  }
}

extension UnmarshallFromList on SharedPreferencesWithCache {
  List<int>? getIntList(String key) {
    return this.getString(key)?.split(',').map(int.parse).toList();
  }
  List<K>? getFromInts<K>(String key, K Function(int) map_f) {
    return this.getIntList(key)?.map(map_f).toList();
  }
  Future<void> setIntList(String key, List<int> ints) {
    return this.setString(key, ints.map((i) => i.toString()).join(','));
  }
}

