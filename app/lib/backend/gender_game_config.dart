import 'utils.dart';
import 'persistence_store.dart';

class GenderGameConfig {
  final int word_cnt;
  final int min_freq;
  final List<TagType> exclude_tags;

  GenderGameConfig(this.word_cnt, this.min_freq, this.exclude_tags);

  static GenderGameConfig load() {
    final s = Persistence.store;
    return GenderGameConfig(
      s.getInt('GenderGameConfig_word_cnt') ?? 10,
      s.getInt('GenderGameConfig_min_freq') ?? 2,
      s.getFromInts<TagType>('GenderGameConfig_exclude_tags',
                             (i) => TagType.values[i]) ?? [],
    );
  }
  Future<void> save() {
    final s = Persistence.store;
    return s.setInt('GenderGameConfig_word_cnt', word_cnt)
            .then((_) => s.setInt('GenderGameConfig_min_freq', min_freq))
            .then((_) => s.setIntList('GenderGameConfig_exclude_tags',
                                      exclude_tags.map((e) => e.index).toList()));
  }
}

