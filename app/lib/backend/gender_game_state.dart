import 'dictionary_entry.dart';
import 'game_config.dart';
import 'utils.dart';
import 'dart:math';

class PastGame {
  final DateTime date;
  final int good;
  final int fail;
  final GameConfig conf;
  PastGame(this.date, this.good, this.fail, this.conf);

  int get word_cnt => good+fail;

  PastGame.fromJson(Map<String, dynamic> json):
    date = DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
    good = json['good'] ?? 0,
    fail = json['fail'] ?? 0,
    conf = GameConfig.fromJson(json['conf'] ?? <String, dynamic>{});

  Map<String, dynamic> toJson() => {
    'date' : date.millisecondsSinceEpoch,
    'good' : good,
    'fail'  : fail,
    'conf'  : conf.toJson(),
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("date: ${date},");
    buf.writeln("good: ${good},");
    buf.writeln("fail: ${fail},");
    buf.writeln("conf: ${conf},");
    return buf.toString();
  }
}

class GenderGameState {
  final DateTime date;
  final List<DEntry> game;
  final List<DEntry> good;
  final List<DEntry> fail;
  final List<Article> guess;
  int idx;

  GenderGameState():
    date = DateTime.now(),
    game = [],
    good = [],
    fail = [],
    guess = [],
    idx = 0;

  GenderGameState.clone(GenderGameState other):
    date = other.date,
    game = other.game.toList(),
    good = other.good.toList(),
    fail = other.fail.toList(),
    guess = other.guess.toList(),
    idx = other.idx;

  DEntry get cur_entry => game[min(idx, game.length-1)];
  bool get isDone => game.length == idx;
  void setWords(List<DEntry> words) => game.addAll(words);

  void advance(bool correct, [Article a = Article.Unknown]) {
    if (isDone) { throw Exception("cannot advance, already at the end"); }
    DEntry entry = game[idx];
    if(correct) { good.add(entry); }
    else {
      fail.add(entry);
      guess.add(a);
    }
    idx += 1;
  }

  PastGame build_past_game(final GameConfig conf) {
    return PastGame(date, good.length, fail.length, conf);
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("date: ${date}");
    buf.writeln("game: ${game.map((e) => e.word).toList()}");
    buf.writeln("good: ${good.map((e) => e.word).toList()}");
    buf.writeln("fail: ${fail.map((e) => e.word).toList()}");
    buf.writeln("guess: ${guess.map((a) => a.name).toList()}");
    buf.writeln("idx: ${idx}");
    return buf.toString();
  }
}

