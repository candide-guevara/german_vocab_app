import 'dart:collection';
import 'dictionary_entry.dart';
import 'game_config.dart';
import 'gender_game_state.dart';
import 'utils.dart';

class HistoryEntry {
  static const int kMaxLen = 20;
  static const int kBaseShift = 24;
  static const int kStrShift = 20;
  static const int kStrHashMask = (1 << kStrShift) - 1;
  static const double kGoodShrink = 0.7;
  static const List<int> kFailShifts = [0,0,1,1,1,2,2,2,2,2];
  static const List<int> kGoodShifts = [0,0,0,0,1,1,1,1,2,2];
  final List<DateTime> goods;
  final List<DateTime> fails;
  // For each fail the bad guess.
  final List<Article> guess;
  final String word;
  final int meaning_idx;

  HistoryEntry.empty(this.word, this.meaning_idx): goods = [], fails = [], guess = [];

  (String, int) key() => (word, meaning_idx);

  int _datesToScore(final List<DateTime> dates, final List<int> shifts) {
    int result = 0;
    for (final (i,dt) in dates.reversed.take(shifts.length).indexed) {
      result += (dt.millisecondsSinceEpoch >> (kBaseShift + shifts[i]));
    }
    return result;
  }
  // Best effort uniqueness per word, this is why we fill the lower bits with the hash.
  // Words which fail often should have a lower rank than words which have been correctly guessed.
  int rank() {
    final int fail_score = _datesToScore(fails, kFailShifts);
    final int good_score = _datesToScore(goods, kGoodShifts);
    final int shifted_score = ((kGoodShrink * good_score).round() - fail_score) << kStrShift;
    return shifted_score + (word.hashCode & kStrHashMask);
  }

  void truncate() {
    int until = goods.length > kMaxLen ? (goods.length-kMaxLen) : 0;
    goods.removeRange(0, until);
    until = fails.length > kMaxLen ? (fails.length-kMaxLen) : 0;
    fails.removeRange(0, until);
  }

  HistoryEntry.fromJson(Map<String, dynamic> json):
    goods = [ for(final d in json['goods'] ?? []) unmarshallLowResolutionDt(d) ],
    fails = [ for(final d in json['fails'] ?? []) unmarshallLowResolutionDt(d) ],
    guess = [ for(final d in json['guess'] ?? []) Article.values[d] ],
    meaning_idx = json['hidx'],
    word = json['lemma'];

  Map<String, dynamic> toJson() => {
    'goods' : [ for(final d in goods) marshallLowResolutionDt(d) ],
    'fails' : [ for(final d in fails) marshallLowResolutionDt(d) ],
    'guess' : [ for(final d in guess) d.index ],
    'hidx' : meaning_idx,
    'lemma' : word,
  };

  String toString() {
    final buf = StringBuffer();
    buf.writeln("goods: ${goods},");
    buf.writeln("fails: ${fails},");
    buf.writeln("guess: ${guess},");
    buf.writeln("meaning_idx: ${meaning_idx},");
    buf.writeln("word: ${word},");
    return buf.toString();
  }
}

class GenderGameHistory {
  static const int kMaxPreviousSampled = 100;
  final List<HistoryEntry> history;
  final List<PastGame> past_games;
  final List<(String, int)> prev_sampled; // not serialized
  final SplayTreeMap<int, int> rank_idx;
  final Map<(String, int), int> rlook_up;
  GenderGameHistory.empty():
    history = [], past_games = [], prev_sampled = [],
    rank_idx = SplayTreeMap<int, int>(), rlook_up = {};

  void appendGamesTo(final bool isCorrect,
                     final DateTime date, final List<DEntry> entries,
                     [final List<Article>? guesses = null]) {
    for (final (i,e) in entries.indexed) {
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
      else {
        h!.guess.add(guesses![i]);
        h!.fails.add(date);
      }
      rank_idx.remove(prev_rank);
      rank_idx[h!.rank()] = idx!;

      // We assume `date` is more recent than previous entries in `h`
      // This keeps history for the word in chrono order.
      h.truncate();
    }
  }

  Iterable<HistoryEntry> allHistoriesByRank() => rank_idx.entries.map((kv) => history[kv.value]);

  Iterable<(String, int)> allWordsByRank() => allHistoriesByRank().map((h) => h.key());

  Iterable<HistoryEntry> failHistoriesByRank() => rank_idx.entries.where((kv) => kv.key < 0)
                                                                  .map((kv) => history[kv.value]);

  Iterable<(String, int)> failWordsByRank() => failHistoriesByRank().map((h) => h.key());

  void appendFinishedGame(final GenderGameState state, final GameConfig conf) {
    if (!state.isDone) { throw Exception("Appending unfinished game"); }
    past_games.add(state.build_past_game(conf));
    appendGamesTo(true,  state.date, state.good);
    appendGamesTo(false, state.date, state.fail, state.guess);
    prev_sampled.addAll(state.game.map((e) => e.key()));
    int until = prev_sampled.length > kMaxPreviousSampled ? (prev_sampled.length-kMaxPreviousSampled) : 0;
    prev_sampled.removeRange(0, until);
  }

  GenderGameHistory.fromJson(Map<String, dynamic> json):
    history = (json?['history'] ?? []).map<HistoryEntry>((d) => HistoryEntry.fromJson(d)).toList(),
    past_games = (json?['past_games'] ?? []).map<PastGame>((d) => PastGame.fromJson(d)).toList(),
    prev_sampled = [],
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

