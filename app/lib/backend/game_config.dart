import 'utils.dart';
import 'exception.dart';
import 'persistence_store.dart';

class VocabGameConfig extends _GameConfig {
  static const String KPrefix = "VocabGameConfig";
  VocabGameConfig(int word_cnt, int min_freq, int inc_fail, List<TagType> tags)
    : super(KPrefix, word_cnt, min_freq, inc_fail, tags);

  VocabGameConfig.def()
    : this(_GameConfig.kWordCnt, _GameConfig.kMinFreq, _GameConfig.kIncludeFailed, _GameConfig.kExcludeTags);

  static Future<_GameConfig> load() async => _GameConfig._load(KPrefix);
}

class GenderGameConfig extends _GameConfig {
  static const String KPrefix = "GenderGameConfig";
  GenderGameConfig(int word_cnt, int min_freq, int inc_fail, List<TagType> tags)
    : super(KPrefix, word_cnt, min_freq, inc_fail, tags);

  GenderGameConfig.def()
    : this(_GameConfig.kWordCnt, _GameConfig.kMinFreq, _GameConfig.kIncludeFailed, _GameConfig.kExcludeTags);

  static Future<_GameConfig> load() async => _GameConfig._load(KPrefix);
}

class _GameConfig {
  static const int kWordCnt = 20;
  static const int kMinFreq = 2;
  static const int kIncludeFailed = 5;
  static final List<TagType> kExcludeTags = List<TagType>.empty();
  final String _prefix;
  int word_cnt;
  int min_freq;
  int inc_fail;
  Set<TagType> exclude_tags;

  _GameConfig(this._prefix, this.word_cnt, this.min_freq, this.inc_fail, List<TagType> tags)
    : exclude_tags = Set<TagType>.of(tags);

  void setFrom(_GameConfig other) {
    word_cnt = other.word_cnt;
    min_freq = other.min_freq;
    inc_fail = other.inc_fail;
    exclude_tags = other.exclude_tags.toSet();
  }

  void reset() {
    word_cnt = kWordCnt;
    min_freq = kMinFreq;
    inc_fail = kIncludeFailed;
    exclude_tags = kExcludeTags.toSet();
  }

  bool has(TagType t) => exclude_tags.contains(t);
  void set(TagType t, {bool remove = false}) {
    if (remove) { exclude_tags.remove(t); }
    else { exclude_tags.add(t); }
  }

  static Future<_GameConfig> _load(final String prefix) async {
    final s = Persistence.store;
    try{
      final cnt =  await s.getInt('${prefix}_word_cnt') ?? kWordCnt;
      final frq =  await s.getInt('${prefix}_min_freq') ?? kMinFreq;
      final inc =  await s.getInt('${prefix}_inc_fail') ?? kIncludeFailed;
      final tag =  await s.getFromInts<TagType>('${prefix}_exclude_tags',
                             (i) => TagType.values[i]) ?? kExcludeTags;
      return _GameConfig(prefix, cnt, frq, inc, tag);
    }
    catch(e,st) {
      throw ExceptionAndStack("${prefix}.load failed", e, st);
    }
  }
  Future<void> save() async {
    final s = Persistence.store;
    try{
      await s.setInt('${_prefix}_word_cnt', word_cnt);
      await s.setInt('${_prefix}_min_freq', min_freq);
      await s.setInt('${_prefix}_inc_fail', inc_fail);
      // Saving an empty list causes a problem when unmarshalling.
      if (exclude_tags.isNotEmpty) {
        await s.setIntList('${_prefix}_exclude_tags',
                           exclude_tags.map((e) => e.index).toList());
      }
      else {
        await s.remove('${_prefix}_exclude_tags');
      }
    }
    catch(e,st) {
      throw ExceptionAndStack("${_prefix}.save failed", e, st);
    }
  }

  String toString() {
    return """
    word_cnt: ${word_cnt}
    min_freq: ${min_freq}
    inc_fail: ${inc_fail}
    exclude_tags: ${exclude_tags.map((e) => e.toString()).toList()}
    """;
  }
}

