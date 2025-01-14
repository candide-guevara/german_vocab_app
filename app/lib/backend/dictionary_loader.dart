import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dictionary.dart';

class DictionaryLoader {
  static final String kBundlePath = 'assets/words.json.gz';
  static final _stats = DictionaryLoadingStats();
  static bool init_called = false;
  static Future<Dictionary> _loadingFuture = Future.error(Exception('Uninitialized'));
  static Dictionary _jsonDict = Dictionary.empty();
  static Dictionary get d => _jsonDict;

  static void init() {
    if (!init_called) {
      init_called = true;
      _stats.start();
      // I think the rootBundle is only avalialble in the main isolate.
      // This is the reason why we chain futures.
      _loadingFuture = rootBundle.load(kBundlePath)
        .then((data) => DictionaryLoader.unmarshalCompressedJson(data));
    }
  }

  static Future<bool> isLoaded() async {
    if (!init_called) throw DeferredLoadException("call init first");
    if(!_jsonDict.isEmpty) return true;
    _jsonDict = await _loadingFuture;
    if(_jsonDict.isEmpty) throw DeferredLoadException("failed to load Dictionary at ${kBundlePath}");
    return true;
  }

  static Future<Dictionary> unmarshalCompressedJson(ByteData compressedData) {
    _stats.doneLoadBundle();
    return Isolate.run(() {
      final Uint8List compressedBytes = compressedData.buffer.asUint8List();
      final decompressedStream = GZipCodec().decoder.convert(compressedBytes);
      _stats.doneDecompress();
      final jsonString = utf8.decode(decompressedStream);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _stats.doneUnmarshal();
      var d = Dictionary(jsonData);
      _stats.doneIndexing();
      //print(stats.toString());
      return d;
    });
  }
}

class DictionaryLoadingStats {
  final Stopwatch _watch;
  int load_bundle_millis = 0;
  int decompress_millis = 0;
  int unmarshal_millis = 0;
  int indexing_millis = 0;

  DictionaryLoadingStats(): _watch = Stopwatch();

  void start() => _watch.start();

  void doneLoadBundle() {
    load_bundle_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneDecompress() {
    decompress_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneUnmarshal() {
    unmarshal_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneIndexing() {
    indexing_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("load_bundle_millis: ${load_bundle_millis}");
    buf.writeln("decompress_millis: ${decompress_millis}");
    buf.writeln("unmarshal_millis: ${unmarshal_millis}");
    buf.writeln("indexing_millis: ${indexing_millis}");
    return buf.toString();
  }
}

