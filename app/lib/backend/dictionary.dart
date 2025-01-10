import 'dictionary_entry.dart';
import 'dictionary_index.dart';
import 'gender_game_config.dart';
import 'utils.dart';

class Dictionary {
  final Map<String, dynamic> _d;
  final DIndex<int> _i_frequency;
  final DIndex<PosType> _i_pos;
  final DIndex<TagType> _i_tag;
  bool get isEmpty => _d.isEmpty;

  Dictionary(Map<String, dynamic> d):
    _d = d,
    _i_frequency = DIndex.from<int>(d, (o) => o['freq']),
    _i_pos = DIndex.from<PosType>(d, (o) => PosType.values[o['pos']]),
    _i_tag = DIndex.fromMulti<TagType>(d, (o) => [ for (final i in o['tags']) TagType.values[i] ]);
  Dictionary.empty(): this(<String, dynamic>{});

  DEntry byIdx(int idx) => DEntry.fromJson(_d['entries'][idx]);

  List<DEntry> sampleGameWords(GenderGameConfig conf) {
    var watch = Stopwatch();
    watch.start();
    final candidates = _i_pos.clone(PosType.Substantiv)
                             .intersectWith<int>(_i_frequency, (i) => i >= conf.min_freq)
                             .intersectWith<TagType>(_i_tag, (t) => !conf.exclude_tags.contains(t))
                             .toList(growable: false);
    candidates.shuffle();
    List<DEntry> result = candidates.map(byIdx)
                                    .skipWhile((o) => o.articles.isEmpty)
                                    .take(conf.word_cnt).toList();
    if(result.length < conf.word_cnt) {
      throw Exception("GenderGameConfig are too restrictive could not get enough candidates");
    }
    watch.stop();
    //print("sampleGameWords took ${watch.elapsedMilliseconds} ms");
    return result;
  }
}

