import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  static void test_only_init(SharedPreferencesWithCache store) {
    init_called = true;
    _loadingStore = Future.value(store);
  }

  static Future<bool> isLoaded() async {
    if (!init_called) throw DeferredLoadException("call init first");
    if(_store != null) return true;
    _store = await _loadingStore;
    return true;
  }

  static String dumpPersistence() {
    var buf = StringBuffer();
    buf.writeln('Persistence store dump:');
    for (final k in Persistence.store.keys) {
      buf.writeln("key: ${k} value: ${Persistence.store.get(k)}");
    }
    buf.writeln('Persistence store dump: END');
    return buf.toString();
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

  Map<String, dynamic>? getJson(String key) {
    String? base64Encoded = this.getString(key);
    if (base64Encoded == null) { return null; }
    final decodedBytes = base64.decode(base64Encoded!);
    final decompressedBytes = gzip.decode(decodedBytes);
    final jsonString = utf8.decode(decompressedBytes);
    return json.decode(jsonString);
  }
  Future<void> setJson(String key, Map<String, dynamic> jsonObj) {
    final jsonString = json.encode(jsonObj);
    final utf8Bytes = utf8.encode(jsonString);
    final compressedBytes = gzip.encode(utf8Bytes);
    final base64Encoded = base64.encode(compressedBytes);
    return this.setString(key, base64Encoded);
  }
}

