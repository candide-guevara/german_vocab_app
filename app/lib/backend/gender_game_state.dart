import 'dictionary_entry.dart';
import 'dart:math';

class PastGame {
  final DateTime date;
  final int good;
  final int bad;
  PastGame(this.date, this.good, this.bad);

  PastGame.fromJson(Map<String, dynamic> json):
    date = DateTime.fromMillisecondsSinceEpoch(json['date']),
    good = json['good'],
    bad  = json['bad'];

  Map<String, dynamic> toJson() => {
    'date' : date.millisecondsSinceEpoch,
    'good' : good,
    'bad'  : bad,
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("date: ${date},");
    buf.writeln("good: ${good},");
    buf.writeln("bad: ${bad},");
    return buf.toString();
  }
}

class GenderGameState {
  final DateTime date;
  final List<DEntry> game;
  final List<DEntry> good;
  final List<DEntry> bad;
  int _idx;

  GenderGameState():
    date = DateTime.now(),
    game = [],
    good = [],
    bad = [],
    _idx = 0;

  GenderGameState.clone(GenderGameState other):
    date = other.date,
    game = other.game.toList(),
    good = other.good.toList(),
    bad = other.bad.toList(),
    _idx = other._idx;

  DEntry get cur_entry => game[min(_idx, game.length-1)];
  bool get isDone => game.length == _idx;
  void setWords(List<DEntry> words) => game.addAll(words);

  void advance(bool correct) {
    if (isDone) { throw Exception("cannot advance, already at the end"); }
    DEntry entry = game[_idx];
    if(correct) { good.add(entry); }
    else { bad.add(entry); }
    _idx += 1;
  }

  PastGame build_past_game() { return PastGame(date, good.length, bad.length); }
}

