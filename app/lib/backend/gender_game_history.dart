import 'dictionary.dart';
import 'dictionary_entry.dart';
import 'gender_game_state.dart';

class HistoryEntry {
  static const int kMaxLen = 10;
  final List<DateTime> goods;
  final List<DateTime> fails;
  final String word;
  final int meaning_idx;

  HistoryEntry.empty(this.word, this.meaning_idx): goods = [], fails = [];

  (String, int) key() => (word, meaning_idx);

  void truncate() {
    int until = goods.length > kMaxLen ? (goods.length-kMaxLen) : 0;
    goods.removeRange(0, until);
    until = fails.length > kMaxLen ? (fails.length-kMaxLen) : 0;
    fails.removeRange(0, until);
  }

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

  void appendFinishedGame(final GenderGameState state) {
    if (!state.isDone) { throw Exception("Appending unfinished game"); }
    past_games.add(state.build_past_game());
    final rLookUp = Map<(String, int), int>.fromEntries(history.indexed.map( (t) => MapEntry(t.$2.key(), t.$1) ));
    int i = 0;
    for (final e in state.good.followedBy(state.fail)) {
      HistoryEntry? h;
      if (rLookUp.containsKey(e.key())) { h = history[rLookUp[e.key()]!]; }
      else { h = HistoryEntry.empty(e.word, e.meaning_idx); history.add(h!); }
      // We assume `state.date` is more recent than previous entries in `h`
      // This keeps history for the word in chrono order.
      if (i < state.good.length) { h!.goods.add(state.date); }
      else { h!.fails.add(state.date); }
      h.truncate();
      i += 1;
    }
  }

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
    history.take(5).forEach(buf.writeln);
    buf.writeln("## past_games");
    past_games.take(5).forEach(buf.writeln);
    return buf.toString();
  }
}

