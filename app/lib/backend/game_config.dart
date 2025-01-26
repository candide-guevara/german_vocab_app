import 'utils.dart';
import 'exception.dart';
import 'persistence_store.dart';

class GameConfig {
  static const int kWordCnt = 20;
  static const int kMinFreq = 2;
  static const int kIncludeFailed = 5;
  static const String kGenderKey = "GenderGameConfig";
  static const String kVocabKey = "VocabGameConfig";
  static final List<TagType> kExcludeTags = List<TagType>.empty();
  int word_cnt;
  int min_freq;
  int inc_fail;
  Set<TagType> exclude_tags;

  GameConfig(this.word_cnt, this.min_freq, this.inc_fail, Iterable<TagType> tags)
    : exclude_tags = Set<TagType>.of(tags);

  GameConfig.def()
    : this(kWordCnt, kMinFreq, kIncludeFailed, kExcludeTags);

  GameConfig.clone(final GameConfig other)
    : this(other.word_cnt, other.min_freq, other.inc_fail, other.exclude_tags);

  GameConfig.fromJson(final Map<String, dynamic> jsonObj)
    : word_cnt = jsonObj['w'] ?? jsonObj['word_cnt'] ?? kWordCnt,
      min_freq = jsonObj['m'] ?? jsonObj['min_freq'] ?? kMinFreq,
      inc_fail = jsonObj['i'] ?? jsonObj['inc_fail'] ?? kIncludeFailed,
      exclude_tags = (jsonObj['e'] ?? jsonObj['exclude_tags'] ?? []).map<TagType>((i) => TagType.values[i]).toSet();

  Map<String, dynamic> toJson() => {
    'w': word_cnt,
    'm': min_freq,
    'i': inc_fail,
    'e': exclude_tags.map((t) => t.index).toList(growable:false),
  };

  void setFrom(GameConfig other) {
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

  static Future<GameConfig> load(final String prefix) async {
    try{
      final s = Persistence.store;
      final Map<String, dynamic>? jsonObj = s.getJson(prefix);
      if (jsonObj == null) { return GameConfig.def(); }
      return GameConfig.fromJson(jsonObj!);
    }
    catch(e,st) {
      throw ExceptionAndStack("${prefix}.load failed", e, st);
    }
  }
  Future<void> save(final String prefix) async {
    try{
      final s = Persistence.store;
      final jsonObj = toJson();
      await s.setJson(prefix, jsonObj);
    }
    catch(e,st) {
      throw ExceptionAndStack("${prefix}.save failed", e, st);
    }
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("word_cnt: ${word_cnt}");
    buf.writeln("min_freq: ${min_freq}");
    buf.writeln("inc_fail: ${inc_fail}");
    buf.writeln("exclude_tags: ${exclude_tags.map((e) => e.toString()).toList()}");
    return buf.toString();
  }
}

