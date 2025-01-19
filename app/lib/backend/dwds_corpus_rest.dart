import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:isolate';

final List<String> kUrlRoots = [
  'https://www.dwds.de/r/?corpus=dwdsxl&sc=bz&sc=blogs&sc=tsp&sc=wikipedia&format=full&sort=date_desc&limit=30&view=json&q=',
  'https://www.dwds.de/r/?corpus=dwdsxl&sc=adg&sc=kern&sc=kern21&sc=wikibooks&format=full&sort=date_desc&limit=30&view=json&q=',
];
final int kMinCorpusSentences = 5;

class Corpus {
  static final kLineTerm = RegExp(r'(\r?\n)+');
  static final kItemSep = RegExp(r'\t+');
  static final kEmpty = RegExp(r'^\s*$');
  static final kGermanChars = RegExp(r'[a-zA-ZäöüÄÖÜß0-9 ,\.]');
  static final int kMinSentenceLen = 64;
  static final int kMaxSentenceLen = 256;
  static final double kGermanCharRatio = 0.93;
  final List<String> sentences;
  final List<(int, int)> token_pos;
  Corpus.empty(): sentences = [], token_pos = [];

  Corpus.fromTsv(final String response, final Uri url)
      : sentences = [], token_pos = [] {
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

  static (int, List<String>) collectWords(List<dynamic> jsonList, bool start) {
    int end = 0;
    List<String> words = [];
    const String kSpace = ' ';
    for (final Map<String, dynamic> o in jsonList) {
      if (!start && (o['ws'] ?? '0') == '1') {
        end += 1;
        words.add(kSpace);
      }
      words.add(o['w']!);
      end += words.last.length + (start?1:0);
      start = false;
    }
    return (end, words);
  }

  static bool sentenceFilter(final String sentence) {
    if (sentence.length < kMinSentenceLen) { return false; }
    if (sentence.length > kMaxSentenceLen) { return false; }
    final int german_char_cnt = kGermanChars.allMatches(sentence).toList().length;
    final double ratio = german_char_cnt / sentence.length;
    if (ratio < kGermanCharRatio) { return false; }
    return true;
  }
  
  void appendJson(final List<dynamic> response, final Uri url) {
    for(final Map<String, dynamic> obj in response) {
      final Map<String, dynamic>? kwic = obj["kwic"];
      if (kwic == null) { continue; }
      final (end_ls, ls_words) = collectWords(kwic['ls'] ?? [], true);
      final (_, rs_words) = collectWords(kwic['rs'] ?? [], end_ls == 0);
      final (end_kw, kw_words) = collectWords(kwic['kw'] ?? [], false);
      final String sentence = ls_words.followedBy(kw_words).followedBy(rs_words).join('');
      if (sentenceFilter(sentence)) {
        token_pos.add((end_ls, end_ls+end_kw-1));
        sentences.add(sentence);
      }
    }
  }

  // Empty hits look like this
  // [{"meta_":{}}]
  Corpus.fromJson(final List<dynamic> response, final Uri url)
      : sentences = [], token_pos = [] {
    appendJson(response, url);
  }
}

Future<Corpus> fetchDwdsCorpusFor(final String word) async {
  return Isolate.run(() async {
    final corpus = Corpus.empty();
    for (final String prefix in kUrlRoots) {
      final url = Uri.parse("${prefix}${word}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.length < 1) { continue; }
        //final corpus = Corpus.fromTsv(response.body, url);
        final List<dynamic> jsonObj = jsonDecode(response.body);
        corpus.appendJson(jsonObj, url);
        if (corpus.sentences.length > kMinCorpusSentences) { return corpus; }
      }
      else { throw Exception("${url} error ${response.statusCode}"); }
    }
    return corpus;
  });
}

