import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:collection';
import 'dart:isolate';

final String _kUrlRoot = 'https://www.openthesaurus.de/synonyme/search?format=application/json&substring=false&similar=false&q=';

class Thesaurus {
  final List<List<String>> synsets;
  // Empty hits look like this
  // "synsets": []
  Thesaurus.fromJson(final Map<String, dynamic> response,
                     final String word,
                     final Uri url)
      : synsets = [] {
    for (final ss in (response['synsets'] ?? [])) {
      final terms = (ss['terms'] ?? []).map<String>((o) => o['term'] as String);
      if (terms.contains(word)) {
        synsets.add(terms.where((w) => w != word).toList(growable: false));
      }
    }
  }
}

Future<Thesaurus> fetchThesaurusFor(final String word) async {
  return Isolate.run(() async {
    final url = Uri.parse("${_kUrlRoot}${word}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body.length < 1) { throw Exception('Bad reponse from ${url}'); }
      final Map<String, dynamic> jsonObj = jsonDecode(response.body);
      return Thesaurus.fromJson(jsonObj, word, url);
    }
    else { throw Exception("${url} error ${response.statusCode}"); }
  });
}


