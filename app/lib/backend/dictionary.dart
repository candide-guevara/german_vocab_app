import 'dictionary_entry.dart';
import 'dictionary_index.dart';
import 'gender_game_config.dart';
import 'gender_game_history.dart';
import 'utils.dart';

class Dictionary {
  final Map<String, dynamic> _d;
  final Map<(String,int),int> _i_word;
  final DIndex<int> _i_frequency;
  final DIndex<PosType> _i_pos;
  final DIndex<TagType> _i_tag;
  bool get isEmpty => _d.isEmpty;

  Dictionary(Map<String, dynamic> d):
    _d = d,
    _i_frequency = DIndex.from<int>(d, (o) => o['freq']),
    _i_pos = DIndex.from<PosType>(d, (o) => PosType.values[o['pos']]),
    _i_tag = DIndex.fromMulti<TagType>(d, (o) => [ for (final i in o['tags']) TagType.values[i] ]),
    _i_word = Dictionary.buildReverseLookUp(d);
  Dictionary.empty(): this(<String, dynamic>{});

  static Map<(String,int),int> buildReverseLookUp(final Map<String, dynamic> d) {
    final Map<(String,int),int> lu = {};
    int i = 0;
    for(final e in d['entries'] ?? []) {
      lu[(e['lemma'], e['hidx'])] = i;
      i++;
    }
    return lu;
  }

  DEntry byIdx(int idx) => DEntry.fromJson(_d['entries'][idx]);
  DEntry byWord(String w, int hidx) => DEntry.fromJson(_d['entries'][_i_word[(w,hidx)]]);
  String wordUrl(DEntry entry) => "${_d['url_root']}${entry.word}";

  List<DEntry> sampleGameWords(GenderGameConfig conf, GenderGameHistory history) {
    final watch = Stopwatch();
    watch.start();
    final candidates = _i_pos.clone(PosType.Substantiv)
                             .intersectWith<int>(_i_frequency, (i) => i >= conf.min_freq)
                             .differenceWith<TagType>(_i_tag, (t) => conf.exclude_tags.contains(t))
                             .toList(growable: false);
    candidates.shuffle();
    final failed_idx = history.failWordsByRank().map((k) => _i_word[k]!)
                                                .take(conf.inc_fail)
                                                .toSet();
    final new_idx = candidates.where((i) => !failed_idx.contains(i));
    final result = failed_idx.followedBy(new_idx)
                             .map(byIdx)
                             .where((o) => o.articles.isNotEmpty)
                             .take(conf.word_cnt)
                             .toList(growable: false);
    if(result.length < conf.word_cnt) {
      throw Exception("GenderGameConfig are too restrictive could not get enough candidates");
    }
    watch.stop();
    //print("sampleGameWords took ${watch.elapsedMilliseconds} ms");
    return result;
  }
}

