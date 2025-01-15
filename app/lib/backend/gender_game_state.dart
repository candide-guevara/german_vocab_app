import 'dictionary_entry.dart';
import 'dart:math';

class PastGame {
  final DateTime date;
  final int good;
  final int fail;
  PastGame(this.date, this.good, this.fail);

  int get word_cnt => good+fail;

  PastGame.fromJson(Map<String, dynamic> json):
    date = DateTime.fromMillisecondsSinceEpoch(json['date']),
    good = json['good'],
    fail  = json['fail'];

  Map<String, dynamic> toJson() => {
    'date' : date.millisecondsSinceEpoch,
    'good' : good,
    'fail'  : fail,
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("date: ${date},");
    buf.writeln("good: ${good},");
    buf.writeln("fail: ${fail},");
    return buf.toString();
  }
}

class GenderGameState {
  final DateTime date;
  final List<DEntry> game;
  final List<DEntry> good;
  final List<DEntry> fail;
  int _idx;

  GenderGameState():
    date = DateTime.now(),
    game = [],
    good = [],
    fail = [],
    _idx = 0;

  GenderGameState.clone(GenderGameState other):
    date = other.date,
    game = other.game.toList(),
    good = other.good.toList(),
    fail = other.fail.toList(),
    _idx = other._idx;

  DEntry get cur_entry => game[min(_idx, game.length-1)];
  bool get isDone => game.length == _idx;
  void setWords(List<DEntry> words) => game.addAll(words);

  void advance(bool correct) {
    if (isDone) { throw Exception("cannot advance, already at the end"); }
    DEntry entry = game[_idx];
    if(correct) { good.add(entry); }
    else { fail.add(entry); }
    _idx += 1;
  }

  PastGame build_past_game() { return PastGame(date, good.length, fail.length); }
}

