import 'dart:convert';
import 'package:test/test.dart';
import 'package:app/backend/dictionary_entry.dart';
import 'package:app/backend/utils.dart';
import 'utils.dart';

void main() {
  test('DEntry_fromJson_and_toJson', () {
    String ini_json = """{
       "articles" : [ ${Article.das.index} ],
       "freq" : 3,
       "hidx" : 2,
       "lemma" : "üppig",
       "pos" : ${PosType.Verb.index},
       "prufung" : ${PrunfungType.a1.index},
       "tags" : [ ${TagType.Funky.index} ],
       "url" : "url"
    }""";
    final entry = DEntry.fromJson(json.decode(ini_json));
    final new_json = json.encode(entry.toJson());
    compareJsonStr(new_json, ini_json);
  });

  test('DEntryEmptyArrays_fromJson_and_toJson', () {
    String ini_json = """{
       "articles" : [],
       "freq" : 3,
       "hidx" : 2,
       "lemma" : "üppig",
       "pos" : ${PosType.Verb.index},
       "prufung" : ${PrunfungType.a1.index},
       "tags" : [],
       "url" : "url"
    }""";
    final entry = DEntry.fromJson(json.decode(ini_json));
    final new_json = json.encode(entry.toJson());
    compareJsonStr(new_json, ini_json);
  });
}

