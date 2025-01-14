import 'dart:convert';
import 'package:app/backend/gender_game_state.dart';
import 'package:test/test.dart';
import 'package:matcher/expect.dart';
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

  test('PastGame_fromJson_and_toJson', () {
    final pg = PastGame(DateTime(2020, 12, 12), 6, 7);
    final jsonObj = pg.toJson();
    final jsonStr = json.encode(jsonObj);
    final new_pg = PastGame.fromJson(json.decode(jsonStr));
    expect(new_pg.toString(), equals(pg.toString()));
  });

  test('GenderGameHistory_fromJson_and_toJson', () {
    final ggh = GenderGameHistory.empty();
    ggh.history.add(HistoryEntry.empty());
    ggh.past_games.add(PastGame(DateTime(2020, 12, 12), 6, 7));
    final jsonObj = ggh.toJson();
    final jsonStr = json.encode(jsonObj);
    final new_ggh = GenderGameHistory.fromJson(json.decode(jsonStr));
    // BE CAREFUL IT IS A TRAP!
    // `expect` fails to compare normal objects...
    expect(new_ggh.toString(), equals(ggh.toString()));
  });

  test('GenderGameHistory_fromJson_and_toJson_empty', () {
    final ggh = GenderGameHistory.empty();
    final jsonObj = ggh.toJson();
    final jsonStr = json.encode(jsonObj);
    final new_ggh = GenderGameHistory.fromJson(json.decode(jsonStr));
    expect(new_ggh.toString(), equals(ggh.toString()));
  });
}

