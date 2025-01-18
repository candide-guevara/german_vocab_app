import 'dart:convert';
import 'package:test/test.dart';
import 'package:german_vocab_app/backend/dictionary.dart';
import 'package:german_vocab_app/backend/game_config.dart';
import 'package:german_vocab_app/backend/gender_game_history.dart';
import 'package:german_vocab_app/backend/utils.dart';

final kTestJsonDict = """ {
  "alternate_spellings" : {},
  "entries" : [
    {
      "articles" : [ ${Article.der.index} ],
      "freq" : 4,
      "hidx" : 0,
      "lemma" : "Anlagemöglichkeit",
      "pos" : ${PosType.Substantiv.index},
      "prufung" : ${PrunfungType.b1.index},
      "tags" : [],
      "url" : "Anlagemoeglichkeit#1"
    },
    {
      "articles" : [ ${Article.der.index} ],
      "freq" : 4,
      "hidx" : 0,
      "lemma" : "Erscheinungsdatum",
      "pos" : ${PosType.Substantiv.index},
      "prufung" : ${PrunfungType.b1.index},
      "tags" : [],
      "url" : "Erscheinungsdatum#1"
    },
    {
      "articles" : [ ${Article.der.index} ],
      "freq" : 4,
      "hidx" : 0,
      "lemma" : "Extraktion",
      "pos" : ${PosType.Substantiv.index},
      "prufung" : ${PrunfungType.b1.index},
      "tags" : [],
      "url" : "Extraktion#1"
    },
    {
      "articles" : [],
      "freq" : 3,
      "hidx" : 0,
      "lemma" : "großartig",
      "pos" : ${PosType.Adjektiv.index},
      "prufung" : ${PrunfungType.Unknown.index},
      "tags" : [],
      "url" : "gro%C3%9Fartig"
    },
    {
      "articles" : [ ${Article.der.index} ],
      "freq" : 4,
      "hidx" : 0,
      "lemma" : "Hund",
      "pos" : ${PosType.Substantiv.index},
      "prufung" : ${PrunfungType.a1.index},
      "tags" : [],
      "url" : "Hund#1"
    },
    {
      "articles" : [ ${Article.der.index} ],
      "freq" : 4,
      "hidx" : 0,
      "lemma" : "Kranich",
      "pos" : ${PosType.Substantiv.index},
      "prufung" : ${PrunfungType.b1.index},
      "tags" : [],
      "url" : "Kranich#1"
    },
    {
      "articles" : [],
      "freq" : 5,
      "hidx" : 0,
      "lemma" : "machen",
      "pos" : ${PosType.Verb.index},
      "prufung" : ${PrunfungType.a2.index},
      "tags" : [],
      "url" : "machen"
    }
  ],
  "url_root" : "https://www.dwds.de/wb/"
}""";

final kHistJson = """{
  "history" : [
    {
      "fails" : [],
      "goods" : [ 1737076244879 ],
      "hidx" : 0,
      "lemma" : "Kranich"
    },
    {
      "fails" : [ 1737076244879 ],
      "goods" : [],
      "hidx" : 0,
      "lemma" : "Anlagemöglichkeit"
    },
    {
      "fails" : [],
      "goods" : [ 1737076244879 ],
      "hidx" : 0,
      "lemma" : "Extraktion"
    },
    {
      "fails" : [ 1737076244879 ],
      "goods" : [],
      "hidx" : 0,
      "lemma" : "Erscheinungsdatum"
    }
  ],
  "past_games" : [
    {
      "date" : 1737076244879,
      "fail" : 8,
      "good" : 2
    }
  ]
}""";

void main() {
  test("sampleGameWords", () {
    final Map<String, dynamic> dictJson = json.decode(kTestJsonDict);
    final tot_nouns = 5;
    final fail_words = ["Erscheinungsdatum", "Anlagemöglichkeit"];

    final Map<String, dynamic> histJson = json.decode(kHistJson);
    final history = GenderGameHistory.fromJson(histJson);

    final conf = GenderGameConfig(tot_nouns-1, 0, fail_words.length, []);
    final d = Dictionary(dictJson);

    // Try several samples.
    for (var i = 0; i < 10; i++) {
      final words = d.sampleGameWords(conf, history);
      expect(words.length, equals(conf.word_cnt));
      expect(words.map((e) => e.word).toSet().length, equals(conf.word_cnt));
      expect(words.map((e) => e.word), containsAll(fail_words));
    }
  });
}

