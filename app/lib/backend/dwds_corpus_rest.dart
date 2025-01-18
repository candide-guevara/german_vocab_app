import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:isolate';

final List<String> kUrlRoots = [
  'https://www.dwds.de/r/?view=tsv&corpus=kern21&genre=Zeitung&q=',
  'https://www.dwds.de/r/?view=tsv&corpus=kern&genre=Zeitung&q=',
  'https://www.dwds.de/r/?view=tsv&corpus=kern21&q=',
  'https://www.dwds.de/r/?view=tsv&corpus=kern&q=',
];

class Corpus {
  static final kLineTerm = RegExp(r'(\r?\n)+');
  static final kItemSep = RegExp(r'\t+');
  static final kEmpty = RegExp(r'^\s*$');
  final List<String> sentences;
  Corpus.empty(): sentences = [];

  Corpus.fromTsv(final String response, final Uri url)
      : sentences = [] {
    final lines = response.split(kLineTerm);
    final idx = lines[0].split(kItemSep).indexWhere((tok) {
      return "Hit" == tok;
    });
    if (idx < 0) { throw Exception("Bad header in tsv: ${lines[0]}\n${url}"); }
    for(final String line in lines.skip(1).where((line) => !kEmpty.hasMatch(line))) {
      final tokens = line.split(kItemSep);
      // When there are no hits it looks like this
      // No.	Date	Genre	Bibl	Hit
      // 1
      if (idx >= tokens.length) { continue; }
      //{ throw Exception("Bad tsv line: ${tokens}\n{$url}"); }
      sentences.add(tokens[idx]);
    }
  }
}

Future<Corpus> fetchDwdsCorpusFor(final String word) async {
  return Isolate.run(() async {
    for (final String prefix in kUrlRoots) {
      final url = Uri.parse("${prefix}${word}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.length < 1) { continue; }
        final corpus = Corpus.fromTsv(response.body, url);
        if (corpus.sentences.isNotEmpty) { return corpus; }
      }
      else { throw Exception("${url} error ${response.statusCode}"); }
    }
    return Corpus.empty();
  });
}

