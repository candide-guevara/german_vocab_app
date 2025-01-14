import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFake implements SharedPreferencesWithCache {
  final _kv = Map<String, dynamic>();

  @override
  Future<void> clear() async { _kv.clear(); return Future.value(); }
  @override
  bool containsKey(String key) { return _kv.containsKey(key); }
  @override
  Set<String> get keys => _kv.keys.toSet();
  @override
  Future<void> reloadCache() async { return Future.value(); }

  @override
  Object? get(String key) { return _kv[key]; }
  @override
  bool? getBool(String key) { return _kv[key] as bool?; }
  @override
  double? getDouble(String key) { return _kv[key] as double?; }
  @override
  int? getInt(String key) { return _kv[key] as int?; }
  @override
  String? getString(String key) { return _kv[key] as String?; }
  @override
  List<String>? getStringList(String key) { return _kv[key] as List<String>?; }

  @override
  Future<void> remove(String key) async { return _kv.remove(key); }
  @override
  Future<void> setBool(String key, bool value) async { _kv[key] = value; return Future.value(); }
  @override
  Future<void> setDouble(String key, double value) async { _kv[key] = value; return Future.value(); }
  @override
  Future<void> setInt(String key, int value) async { _kv[key] = value; return Future.value(); }
  @override
  Future<void> setString(String key, String value) async { _kv[key] = value; return Future.value(); }
  @override
  Future<void> setStringList(String key, List<String> value) async { _kv[key] = value; return Future.value(); }
}

