import 'dart:convert';
import 'package:test/test.dart';
import 'package:app/backend/gender_game_state.dart';
import 'utils.dart';

void main() {
  test('HistoryEntry_fromJson_and_toJson', () {
    String ini_json = """{
       "goods" : [ ${DateTime.now().millisecondsSinceEpoch} ],
       "fails" : [ ${DateTime.now().millisecondsSinceEpoch} ],
       "hidx" : 2,
       "lemma" : "üppig"
    }""";
    final entry = HistoryEntry.fromJson(json.decode(ini_json));
    final new_json = json.encode(entry.toJson());
    compareJsonStr(new_json, ini_json);
  });

  test('HistoryEntryEmptyArrays_fromJson_and_toJson', () {
    String ini_json = """{
       "goods" : [],
       "fails" : [],
       "hidx" : 2,
       "lemma" : "üppig"
    }""";
    final entry = HistoryEntry.fromJson(json.decode(ini_json));
    final new_json = json.encode(entry.toJson());
    compareJsonStr(new_json, ini_json);
  });
}

