import 'utils.dart';

class DIndex<K> {
  final Map<K, Set<int>> m;
  const DIndex(this.m);
  Set<int> clone(K k) { return Set<int>.of(m[k]!); }

  static DIndex<T> from<T>(Map<String, dynamic> d,
                           T Function(Map<String, dynamic>) f) {
    return DIndex.fromMulti<T>(d, (o) => <T>[f(o)]);
  }
  static DIndex<T> fromMulti<T>(Map<String, dynamic> d,
                                List<T> Function(Map<String, dynamic>) f) {
    Map<T, Set<int>> m = <T, Set<int>>{};
    int i = 0;
    for (final o in (d['entries'] ?? <dynamic>[])) {
      for (final k in f(o)) { m.putIfAbsent(k, () => <int>{}).add(i); }
      i += 1;
    }
    return DIndex<T>(m);
  }
}

extension ChainMerge on Set<int> {
  Set<int> intersectWith<K>(DIndex<K> index, bool Function(K) pick) {
    final keys = index.m.keys.where(pick).toList();
    Set<int> s = {};
    for (final k in keys) { s.addAll(index.m[k]!); }
    this.retainWhere(s.contains);
    return this;
  }
  Set<int> differenceWith<K>(DIndex<K> index, bool Function(K) pick) {
    final keys = index.m.keys.where(pick).toList();
    if (keys.isEmpty) { return this; }
    Set<int> s = {};
    for (final k in keys) { s.addAll(index.m[k]!); }
    this.removeWhere(s.contains);
    return this;
  }
}

