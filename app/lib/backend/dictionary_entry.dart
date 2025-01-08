import '../utils.dart';

class DEntry {
  final List<Article> articles;
  final int frequency;
  final int meaning_idx;
  final String word;
  final PosType pos;
  final PrunfungType prufung;
  final List<TagType> tags;
  final String url;

  DEntry.fromJson(Map<String, dynamic> json)
      : articles = [ for (var x in json['articles']) RArticle[x] ?? Article.Unknown ],
        frequency = json['freq'],
        meaning_idx = json['hidx'],
        word = json['lemma'],
        pos = PosType.values[json['pos']],
        prufung = RPrunfungType[json['prufung']] ?? PrunfungType.Unknown,
        tags = [ for (var x in json['tags']) TagType.values[x] ],
        url = json['url'];
}

