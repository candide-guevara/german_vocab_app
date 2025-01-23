import 'dictionary_entry.dart';
import 'dictionary_index.dart';
import 'game_config.dart';
import 'gender_game_history.dart';
import 'vocab_game_history.dart';
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
  String wordUrl(DEntry entry) => "${_d['url_root']}${entry.url}";

  List<DEntry> sampleVocabGameWords(VocabGameConfig conf, VocabGameHistory history) {
    final include_type = [PosType.Substantiv, PosType.Verb, PosType.Adjektiv, PosType.Adverb,];
    final candidates = _i_pos.cloneMatching((k) => include_type.contains(k))
                             .intersectWith<int>(_i_frequency, (i) => i >= conf.min_freq)
                             .differenceWith<TagType>(_i_tag, (t) => conf.exclude_tags.contains(t));
    return combineCandidateWithPreviousFails(conf.word_cnt, conf.inc_fail, candidates,
                                             history.failWordsByRank().map((k) => _i_word[k]!),
                                             history.prev_sampled,
                                             (_) => true);
  }

  List<DEntry> sampleGenderGameWords(GenderGameConfig conf, GenderGameHistory history) {
    final candidates = _i_pos.clone(PosType.Substantiv)
                             .intersectWith<int>(_i_frequency, (i) => i >= conf.min_freq)
                             .differenceWith<TagType>(_i_tag, (t) => conf.exclude_tags.contains(t));
    return combineCandidateWithPreviousFails(conf.word_cnt, conf.inc_fail, candidates,
                                             history.failWordsByRank().map((k) => _i_word[k]!),
                                             history.prev_sampled,
                                             (o) => o.articles.isNotEmpty && o.meaning_idx < 2);
  }

  List<DEntry> combineCandidateWithPreviousFails(final int word_cnt, final int inc_fail,
                                                 final Iterable<int> candidate_it,
                                                 final Iterable<int> fail_it,
                                                 final Iterable<(String, int)> prev_sampled,
                                                 bool Function(DEntry) filter) {
    final prev_set = prev_sampled.map((k) => _i_word[k] ?? 0).toSet();
    final candidates = candidate_it.toList(growable: false);
    candidates.shuffle();
    final failed_idx = fail_it.take(3 * inc_fail)
                              .toList(growable: false);
    failed_idx.shuffle();
    final new_idx = candidates.where((i) => !failed_idx.contains(i) && !prev_set.contains(i));
    final result = failed_idx.take(inc_fail)
                             .followedBy(new_idx)
                             .map(byIdx)
                             .where(filter)
                             .take(word_cnt)
                             .toList(growable: false);
    result.shuffle();
    if(result.length < word_cnt) {
      throw Exception("Could not find enough candidates");
    }
    return result;
  }
}

