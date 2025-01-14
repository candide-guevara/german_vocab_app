import 'dart:convert';
import 'package:app/backend/dictionary_entry.dart';
import 'package:app/backend/gender_game_state.dart';
import 'package:test/test.dart';
import 'package:matcher/expect.dart';
import 'utils.dart';

void main() {
  test('PastGame_fromJson_and_toJson', () {
    final pg = PastGame(DateTime(2020, 12, 12), 6, 7);
    final jsonObj = pg.toJson();
    final jsonStr = json.encode(jsonObj);
    final new_pg = PastGame.fromJson(json.decode(jsonStr));
    expect(new_pg.toString(), equals(pg.toString()));
  });
}

