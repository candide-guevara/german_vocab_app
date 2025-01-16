import 'dart:collection';
import 'dictionary_entry.dart';
import 'gender_game_state.dart';

class HistoryEntry {
  static const int kMaxLen = 10;
  static const int kBaseShift = 24;
  static const int kStrShift = 20;
  static const int kStrHashMask = (1 << kStrShift) - 1;
  static const double kGoodShrink = 0.7;
  // `shifts.length` should be kMaxLen;
  static const List<int> shifts = [0,0,1,1,1,2,2,2,2,2];
  final List<DateTime> goods;
  final List<DateTime> fails;
  final String word;
  final int meaning_idx;

  HistoryEntry.empty(this.word, this.meaning_idx): goods = [], fails = [];

  (String, int) key() => (word, meaning_idx);

  int _dateToScore(final int acc, final (int, DateTime) t) {
    final (i,dt) = t;
    return acc + (dt.millisecondsSinceEpoch >> (kBaseShift + shifts[i]));
  }
  // Best effort uniqueness per word, this is why we fill the lower bits with the hash.
  int rank() {
    final int fail_score = fails.indexed.take(kMaxLen).fold(0, _dateToScore);
    final int good_score = goods.indexed.take(kMaxLen).fold(0, _dateToScore);
    final int shifted_score = (fail_score - (kGoodShrink * good_score).round()) << kStrShift;
    return shifted_score + (word.hashCode & kStrHashMask);
  }

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
  final List<HistoryEntry> history;
  final List<PastGame> past_games;
  final SplayTreeMap<int, int> rank_idx;
  final Map<(String, int), int> rlook_up;
  GenderGameHistory.empty():
    history = [], past_games = [], rank_idx = SplayTreeMap<int, int>(), rlook_up = {};

  void appendGamesTo(final bool isCorrect, final DateTime date, final List<DEntry> entries) {
    for (final e in entries) {
      HistoryEntry? h;
      int? idx = rlook_up[e.key()];
      if (idx != null) { h = history[idx]; }
      else {
        idx = history.length;
        h = HistoryEntry.empty(e.word, e.meaning_idx);
        history.add(h!);
        rlook_up[h!.key()] = idx!;
      }

      final prev_rank = h!.rank();
      if (isCorrect) { h!.goods.add(date); }
      else { h!.fails.add(date); }
      rank_idx.remove(prev_rank);
      rank_idx[h!.rank()] = idx!;

      // We assume `date` is more recent than previous entries in `h`
      // This keeps history for the word in chrono order.
      h.truncate();
    }
  }

  Iterable<(String, int)> failWordsByRank() => rank_idx.entries.map((kv) => history[kv.value].key());

  void appendFinishedGame(final GenderGameState state) {
    if (!state.isDone) { throw Exception("Appending unfinished game"); }
    past_games.add(state.build_past_game());
    appendGamesTo(true,  state.date, state.good);
    appendGamesTo(false, state.date, state.fail);
  }

  GenderGameHistory.fromJson(Map<String, dynamic> json):
    history = (json?['history'] ?? []).map<HistoryEntry>((d) => HistoryEntry.fromJson(d)).toList(),
    past_games = (json?['past_games'] ?? []).map<PastGame>((d) => PastGame.fromJson(d)).toList(),
    rank_idx = SplayTreeMap<int, int>(),
    rlook_up = {} {
      rank_idx.addEntries(history.indexed.map( (t) => MapEntry(t.$2.rank(), t.$1) ));
      rlook_up.addEntries(history.indexed.map( (t) => MapEntry(t.$2.key(), t.$1) ));
  }

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

