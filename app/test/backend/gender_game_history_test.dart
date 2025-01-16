import 'dart:collection';
import 'dart:convert';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/gender_game_history.dart';
import 'package:german_vocab_app/backend/gender_game_state.dart';
import 'package:test/test.dart';
import 'package:matcher/expect.dart';
import 'utils.dart';

void main() {
  test('HistoryEntry_rank', () {
    final int good_dt = 123 << HistoryEntry.kBaseShift;
    final int fail_dt = 321 << HistoryEntry.kBaseShift;
    final String word = "chocolat";
    final int fail_score = (fail_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[0]))
                         + (fail_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[1]))
                         + (fail_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[2]))
                         + (fail_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[3]))
                         + (fail_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[4]));
    final int good_score = (good_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[0]))
                         + (good_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[1]))
                         + (good_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[2]))
                         + (good_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[3]))
                         + (good_dt >> (HistoryEntry.kBaseShift + HistoryEntry.shifts[4]));
    final int score = fail_score - (HistoryEntry.kGoodShrink * good_score).round();
    final int rank_expect = (score << HistoryEntry.kStrShift) + (word.hashCode & HistoryEntry.kStrHashMask);
    String ini_json = """{
       "goods" : [ ${good_dt}, ${good_dt}, ${good_dt}, ${good_dt}, ${good_dt} ],
       "fails" : [ ${fail_dt}, ${fail_dt}, ${fail_dt}, ${fail_dt}, ${fail_dt} ],
       "hidx" : 2,
       "lemma" : "${word}"
    }""";
    final entry = HistoryEntry.fromJson(json.decode(ini_json));
    expect(entry.rank(), equals(rank_expect));
  });

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
    expect(ggh.rlook_up.length, equals(0));
    expect(ggh.rank_idx.length, equals(0));
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
    expect(ggh.rlook_up.length, equals(3));
    expect(ggh.rank_idx.length, equals(3));
    expect(ggh.past_games.length, equals(2));

    ggs.setWords([ DEntry.forTest('new_word', 0), ]);
    ggs.advance(true);

    ggh.appendFinishedGame(ggs);
    expect(ggh.history.length, equals(4));
    expect(ggh.rlook_up.length, equals(4));
    expect(ggh.rlook_up.values, everyElement(inInclusiveRange(0,3)));
    expect(ggh.rank_idx.length, equals(4));
    expect(ggh.rank_idx.values, everyElement(inInclusiveRange(0,3)));
    expect(ggh.rank_idx.keys, everyElement(isNonZero));
    //print(ggh.rank_idx);
    //expect(ggh.toString(), equals(''));
  });

  test('SplayTreeMap_is_sorted', () {
    final m = SplayTreeMap<int, int>();
    m[2] = 3;
    m[4] = 2;
    expect(m.keys, orderedEquals([2,4]));
    m[3] = 3;
    m[1] = 4;
    expect(m.keys, orderedEquals([1,2,3,4]));
  });
}


