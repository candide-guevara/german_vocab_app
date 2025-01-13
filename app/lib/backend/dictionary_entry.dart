import 'utils.dart';

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
      : articles = [ for (final x in json['articles']) Article.values[x] ],
        frequency = json['freq'],
        meaning_idx = json['hidx'],
        word = json['lemma'],
        pos = PosType.values[json['pos']],
        prufung = PrunfungType.values[json['prufung']],
        tags = [ for (var x in json['tags']) TagType.values[x] ],
        url = json['url'];

  Map<String, dynamic> toJson() => {
    'articles': [ for (final a in articles) a.index ],
    'freq': frequency,
    'hidx': meaning_idx,
    'lemma': word,
    'pos': pos.index,
    'prufung': prufung.index,
    'tags':  [ for (final t in tags) t.index ],
    'url': url,
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("articles: ${articles},");
    buf.writeln("frequency: ${frequency},");
    buf.writeln("meaning_idx: ${meaning_idx},");
    buf.writeln("word: ${word},");
    buf.writeln("pos: ${pos},");
    buf.writeln("prufung: ${prufung},");
    buf.writeln("tags: ${tags},");
    buf.writeln("url: ${url},");
    return buf.toString();
  }
}

