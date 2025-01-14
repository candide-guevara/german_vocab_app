import 'utils.dart';
import 'exception.dart';
import 'persistence_store.dart';

class GenderGameConfig {
  static const int kWordCnt = 20;
  static const int kMinFreq = 2;
  static final List<TagType> kExcludeTags = List<TagType>.empty();
  int word_cnt;
  int min_freq;
  Set<TagType> exclude_tags;

  GenderGameConfig(this.word_cnt, this.min_freq, List<TagType> tags)
    : exclude_tags = Set<TagType>.of(tags);

  GenderGameConfig.def(): this(kWordCnt, kMinFreq, kExcludeTags);

  void setFrom(GenderGameConfig other) {
    word_cnt = other.word_cnt;
    min_freq = other.min_freq;
    exclude_tags = other.exclude_tags.toSet();
  }

  void reset() {
    word_cnt = kWordCnt;
    min_freq = kMinFreq;
    exclude_tags = kExcludeTags.toSet();
  }

  bool has(TagType t) => exclude_tags.contains(t);
  void set(TagType t, {bool remove = false}) {
    if (remove) { exclude_tags.remove(t); }
    else { exclude_tags.add(t); }
  }

  static Future<GenderGameConfig> load() async {
    final s = Persistence.store;
    try{
      final cnt =  await s.getInt('GenderGameConfig_word_cnt') ?? kWordCnt;
      final frq =  await s.getInt('GenderGameConfig_min_freq') ?? kMinFreq;
      final tag =  await s.getFromInts<TagType>('GenderGameConfig_exclude_tags',
                             (i) => TagType.values[i]) ?? kExcludeTags;
      return GenderGameConfig(cnt, frq, tag);
    }
    catch(e,st) {
      throw ExceptionAndStack("GenderGameConfig.load failed", e, st);
    }
  }
  Future<void> save() async {
    final s = Persistence.store;
    try{
      await s.setInt('GenderGameConfig_word_cnt', word_cnt);
      await s.setInt('GenderGameConfig_min_freq', min_freq);
      // Saving an empty list causes a problem when unmarshalling.
      if (exclude_tags.isNotEmpty) {
        await s.setIntList('GenderGameConfig_exclude_tags',
                           exclude_tags.map((e) => e.index).toList());
      }
      else {
        await s.remove('GenderGameConfig_exclude_tags');
      }
    }
    catch(e,st) {
      throw ExceptionAndStack("GenderGameConfig.save failed", e, st);
    }
  }

  String toString() {
    return """
    word_cnt: ${word_cnt}
    min_freq: ${min_freq}
    exclude_tags: ${exclude_tags.map((e) => e.toString()).toList()}
    """;
  }
}

