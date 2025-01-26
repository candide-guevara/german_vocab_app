import 'dart:convert';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/game_config.dart';
import 'package:german_vocab_app/backend/gender_game_state.dart';
import 'package:german_vocab_app/backend/utils.dart';
import 'package:test/test.dart';
import 'package:matcher/expect.dart';
import 'utils.dart';

void main() {
  test('PastGame_fromJson_and_toJson', () {
    final conf = GenderGameConfig(10, 3, 9, []);
    final dt = unmarshallDt(marshallDt(DateTime(2020, 12, 12)));
    final pg = PastGame(dt, 6, 7, conf);
    final jsonObj = pg.toJson();
    final jsonStr = json.encode(jsonObj);
    final new_pg = PastGame.fromJson(json.decode(jsonStr));
    expect(new_pg.toString(), equals(pg.toString()));
  });
}

