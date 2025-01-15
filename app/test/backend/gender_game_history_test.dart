import 'dart:convert';
import 'package:app/backend/dictionary_entry.dart';
import 'package:app/backend/gender_game_history.dart';
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

  test('HistoryEntry_truncate', () {
    final entry = HistoryEntry.empty('word', 1);
    final dt = DateTime.now();
    for (var i = 0; i < HistoryEntry.kMaxLen * 2; i++) {
      entry.goods.add(dt);
      entry.fails.add(dt);
    }
    entry.truncate();
    expect(entry.goods.length, equals(HistoryEntry.kMaxLen));
    expect(entry.fails.length, equals(HistoryEntry.kMaxLen));
  });

  test('GenderGameHistory_fromJson_and_toJson', () {
    final ggh = GenderGameHistory.empty();
    ggh.history.add(HistoryEntry.empty('bla', 4));
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

  test('GenderGameHistory_appendFinishedGame', () {
    final ggh = GenderGameHistory.empty();
    final ggs = GenderGameState();

    ggh.appendFinishedGame(ggs);
    expect(ggh.history.length, equals(0));
    expect(ggh.past_games.length, equals(1));

    ggs.setWords([
      DEntry.forTest('foo', 0),
      DEntry.forTest('bar', 0),
      DEntry.forTest('baz', 0),
    ]);
    ggs.advance(true);
    ggs.advance(false);
    ggs.advance(true);

    ggh.appendFinishedGame(ggs);
    expect(ggh.history.length, equals(3));
    expect(ggh.past_games.length, equals(2));

    ggs.setWords([ DEntry.forTest('new_word', 0), ]);
    ggs.advance(true);

    ggh.appendFinishedGame(ggs);
    expect(ggh.history.length, equals(4));
    //expect(ggh.toString(), equals(''));
  });
}


