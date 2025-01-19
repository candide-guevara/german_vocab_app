import 'dart:convert';
import 'package:german_vocab_app/backend/dwds_corpus_rest.dart';
import 'package:matcher/expect.dart';
import 'package:test/test.dart';

void main() {
  test("Corpus_fromTsv", () {
    final rawTsv = """No.\tDate\tGenre\tBibl\tHit
1\t2001-06-11\tZeitung\tDer Spiegel, 11.06.2001\tDazu kommt, dass der Zeitgeist der achtziger Jahre auch im Funktionärskorps der SPD deutliche Spuren hinterlassen hat.
2\t2001-06-02\tZeitung\tDer Spiegel, 02.06.2001\tWas eine ökologische Nische für seinen Vetter, den Steinadler, hinterließ.
3\t2000-12-03\tZeitung\tArchiv der Gegenwart, Bd. 70, 03.12.2000, S. 44653 [ff.]. Zit. n. CD-ROM-Ausgabe 2001.\tFehlt uns der Mut und die Entschlossenheit, dann hinterlassen wir der Zukunft ein schlechtes Erbe, ein Erbe unwürdig jener Gründungsväter wie Schuman, Monnet, Spaak, de Gasperi und Adenauer, die auf diesem Weg der Europäischen Einigung die ersten Schritte gesetzt haben.
4\t2000-12-01\tZeitung\tArchiv der Gegenwart, Bd. 70, 01.12.2000, S. 44631 [ff.]. Zit. n. CD-ROM-Ausgabe 2001.\tSchauen Sie sich doch den ökonomischen Zusammenhang an: Arbeitsplätze wurden vernichtet, in den 90er Jahren gab es Reallohnverluste, weil der Verteilungsspielraum bei den Lohnverhandlungen gegen null tendierte ... Mir geht es auf den Geist, dass Sie sich hier ständig hinstellen und sich auf die Schulter klopfen, obwohl Sie eine absolut desaströse finanzpolitische Situation hinterlassen haben.
    """;
    final corpus = Corpus.fromTsv(rawTsv, Uri.parse("someword"));
    expect(corpus.sentences.length, equals(4));
  });

  test("Corpus_fromJson", () {
    final jsonStr = """[
  {
    "kwic": {
      "kw": [
        { "w": "Kino", "ws": "1", "hl_": 1 }
      ],
      "rs": [
        { "w": "erneut", "ws": "1", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "das" },
        { "w": "Interesse", "ws": "1", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "an" },
        { "ws": "1", "w": "der", "hl_": 0 },
        { "w": "Geschichte", "ws": "1", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "des" },
        { "hl_": 0, "ws": "1", "w": "Vaterlandes" },
        { "w": ",", "ws": "0", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "an" },
        { "hl_": 0, "w": "unseren", "ws": "1" },
        { "ws": "1", "w": "Wurzeln", "hl_": 0 },
        { "w": ".", "ws": "0", "hl_": 0 }
      ],
      "ls": [
        { "hl_": 0, "w": "Und", "ws": "1" },
        { "hl_": 0, "w": "heute", "ws": "1" },
        { "ws": "1", "w": "wächst", "hl_": 0 },
        { "ws": "1", "w": "in", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "unserer" },
        { "hl_": 0, "ws": "1", "w": "Kunst" },
        { "hl_": 0, "ws": "0", "w": "," },
        { "ws": "1", "w": "im", "hl_": 0 },
        { "ws": "1", "w": "Theater", "hl_": 0 },
        { "ws": "0", "w": ",", "hl_": 0 },
        { "w": "im", "ws": "1", "hl_": 0 }
      ]
    }
  },
  {
    "kwic": {
      "kw": [
        { "hl_": 1, "ws": "1", "w": "Kinos" }
      ],
      "ls": [
        { "hl_": 0, "w": "Die", "ws": "1" },
        { "ws": "1", "w": "Verleiher", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "werden" },
        { "w": "sich", "ws": "1", "hl_": 0 },
        { "w": "dieser", "ws": "1", "hl_": 0 },
        { "ws": "1", "w": "Marktmacht", "hl_": 0 },
        { "hl_": 0, "w": "gegenüber", "ws": "1" },
        { "hl_": 0, "ws": "1", "w": "gewogen" },
        { "w": "zeigen", "ws": "1", "hl_": 0 },
        { "ws": "1", "w": "müssen", "hl_": 0 },
        { "hl_": 0, "w": ",", "ws": "0" },
        { "w": "zuungunsten", "ws": "1", "hl_": 0 },
        { "w": "anderer", "ws": "1", "hl_": 0 }
      ],
      "rs": [
        { "ws": "0", "w": ",", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "denen" },
        { "ws": "1", "w": "mancher", "hl_": 0 },
        { "hl_": 0, "ws": "1", "w": "Film" },
        { "hl_": 0, "ws": "1", "w": "künftig" },
        { "w": "vorenthalten", "ws": "1", "hl_": 0 },
        { "ws": "1", "w": "bleibt", "hl_": 0 },
        { "hl_": 0, "w": ".", "ws": "0" }
      ]
    }
  }
]""";
    final List<String> sentences = [
      """Und heute wächst in unserer Kunst, im Theater, im Kino erneut das Interesse an der Geschichte des Vaterlandes, an unseren Wurzeln.""",
      """Die Verleiher werden sich dieser Marktmacht gegenüber gewogen zeigen müssen, zuungunsten anderer Kinos, denen mancher Film künftig vorenthalten bleibt.""",
    ];
    final List<dynamic> jsonObj = jsonDecode(jsonStr);
    final corpus = Corpus.fromJson(jsonObj, Uri.parse("someword"));
    expect(corpus.sentences, orderedEquals(sentences));
    expect(corpus.token_pos, orderedEquals([(50,54), (97,102)]));
  });
}

