import 'dictionary.dart';
import 'dictionary_entry.dart';
import 'persistence_store.dart';

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
}

class HistoryEntry {
  final List<DateTime> goods;
  final List<DateTime> fails;
  final String word;
  final int meaning_idx;

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

class PastGame {
  final DateTime date;
  final int good;
  final int bad;
  PastGame(this.date, this.good, this.bad);
}

class GenderGameHistory {
  List<HistoryEntry> history;
  List<PastGame> past_games;
  GenderGameHistory.empty(): history = [], past_games = [];
}

