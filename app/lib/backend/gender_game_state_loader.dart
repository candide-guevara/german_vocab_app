import 'dart:async';
import 'package:meta/meta.dart';
import 'gender_game_state.dart';
import 'persistence_store.dart';

class GenderGameHistoryLoader {
  static bool init_called = false;
  static final _stats = GenderGameHistoryLoaderStats();
  static Future<GenderGameHistory> _loadingFuture = Future.error(Exception('Uninitialized'));
  static GenderGameHistory? _h;
  static get h => _h!;

  static void init() {
    if (init_called) { return; }
    init_called = true;
    _loadingFuture = Persistence.isLoaded().then( (_) => load() );
  }

  static Future<bool> isLoaded() async {
    if (!init_called) throw DeferredLoadException("call init first");
    if(_h != null) return true;
    _h = await _loadingFuture;
    return true;
  }

  @visibleForTesting
  static Future<GenderGameHistory> load() {
    _stats.start();
    final s = Persistence.store;
    final Map<String, dynamic>? json = s.getJson('GenderGameHistory');
    _stats.doneLoadJson();
    if (json == null) { return Future.value(GenderGameHistory.empty()); }
    final tmp_h = GenderGameHistory.fromJson(json);
    _stats.doneLoadUnmarshal();
    return Future.value(tmp_h);
  }

  static Future<void> save() async {
    _stats.start();
    final json = h.toJson();
    _stats.doneSaveUnmarshal();
    final s = Persistence.store;
    await s.setJson('GenderGameHistory', json);
    _stats.doneSaveJson();
  }
}

class GenderGameHistoryLoaderStats {
  final Stopwatch _watch;
  int load_json_millis = 0;
  int load_unmarshall_millis = 0;
  int save_json_millis = 0;
  int save_unmarshall_millis = 0;

  GenderGameHistoryLoaderStats(): _watch = Stopwatch();

  void start() => _watch.start();

  void doneLoadJson() {
    load_json_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneLoadUnmarshal() {
    load_unmarshall_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneSaveJson() {
    save_json_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }
  void doneSaveUnmarshal() {
    save_unmarshall_millis = _watch.elapsedMilliseconds;
    _watch.reset();
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("load_json_millis: ${load_json_millis}");
    buf.writeln("load_unmarshall_millis: ${load_unmarshall_millis}");
    buf.writeln("save_json_millis: ${save_json_millis}");
    buf.writeln("save_unmarshall_millis: ${save_unmarshall_millis}");
    return buf.toString();
  }
}

