import 'dart:convert';
import 'package:german_vocab_app/backend/thesaurus_rest.dart';
import 'package:matcher/expect.dart';
import 'package:test/test.dart';

void main() {
  test('Thesaurus.fromJson', () {
    final jsonStr = '''{
  "metaData": { "apiVersion": "0.2" },
  "synsets": [{
      "id": 5940,
      "categories": [],
      "terms": [
        { "term": "(jemandem) helfen" },
        { "term": "assistieren" },
        { "term": "behilflich sein" },
        { "term": "sekundieren", "level": "gehoben" }
      ]
    },
    {
      "id": 35410,
      "categories": [],
      "terms": [
        { "term": "betreuen" },
        { "term": "helfen" },
        { "term": "(sich) kümmern" }
      ]
    }
  ]}''';
    final Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
    final thesaurus = Thesaurus.fromJson(jsonObj, 'helfen', Uri.parse("helfen"));
    expect(thesaurus.synsets.length, equals(1));
    expect(thesaurus.synsets[0], orderedEquals(['betreuen', '(sich) kümmern']));
  });
}

