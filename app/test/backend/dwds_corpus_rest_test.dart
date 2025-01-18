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
}

