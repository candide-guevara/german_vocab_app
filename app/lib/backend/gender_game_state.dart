import 'dictionary.dart';
import 'dictionary_entry.dart';

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
  List<DEntry> good;
  List<DEntry> bad;
  GenderGameState():
    date = DateTime.now(),
    good = [],
    bad = [];

  void add(DEntry entry, bool correct) {
    if(correct) { good.add(entry); }
    else { good.add(entry); }
  }

  PastGame done() { return PastGame(date, good.length, bad.length); }
}

class HistoryEntry {
  final List<DateTime> goods;
  final List<DateTime> fails;
  final String word;
  final int meaning_idx;

  HistoryEntry.empty(): goods = [], fails = [], word = '', meaning_idx = 0;

  HistoryEntry.fromJson(Map<String, dynamic> json):
    goods = [ for(final d in json['goods'] ?? []) DateTime.fromMillisecondsSinceEpoch(d) ],
    fails = [ for(final d in json['fails'] ?? []) DateTime.fromMillisecondsSinceEpoch(d) ],
    meaning_idx = json['hidx'],
    word = json['lemma'];

  Map<String, dynamic> toJson() => {
    'goods' : [ for(final d in goods) d.millisecondsSinceEpoch ],
    'fails' : [ for(final d in fails) d.millisecondsSinceEpoch ],
    'hidx' : meaning_idx,
    'lemma' : word,
  };

  DEntry entry(final Dictionary d) => d.byWord(word,meaning_idx);

  String toString() {
    final buf = StringBuffer();
    buf.writeln("goods: ${goods},");
    buf.writeln("fails: ${fails},");
    buf.writeln("meaning_idx: ${meaning_idx},");
    buf.writeln("word: ${word},");
    return buf.toString();
  }
}

class GenderGameHistory {
  List<HistoryEntry> history;
  List<PastGame> past_games;
  GenderGameHistory.empty(): history = [], past_games = [];

  GenderGameHistory.fromJson(Map<String, dynamic> json):
    history = (json?['history'] ?? []).map<HistoryEntry>((d) => HistoryEntry.fromJson(d)).toList(),
    past_games = (json?['past_games'] ?? []).map<PastGame>((d) => PastGame.fromJson(d)).toList();

  Map<String, dynamic> toJson() => {
    'history' :  [ for(final h in history) h.toJson() ],
    'past_games': [ for(final p in past_games) p.toJson() ],
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("## history");
    history.take(3).forEach(buf.writeln);
    buf.writeln("## past_games");
    past_games.take(3).forEach(buf.writeln);
    return buf.toString();
  }
}

