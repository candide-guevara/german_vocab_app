import 'dictionary_entry.dart';
import 'dictionary.dart';
import 'gender_game_history.dart';
import 'utils.dart';

class BadGuess implements Comparable<BadGuess> {
  final Article correct;
  final Article guessed;
  final int count;
  BadGuess(this.correct, this.guessed, this.count);

  @override
  int compareTo(BadGuess other) {
    if (correct != other.correct) {
      return Enum.compareByIndex(correct, other.correct);
    }
    else if (guessed != other.guessed) {
      return Enum.compareByIndex(guessed, other.guessed);
    }
    return 0;
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("correct: ${correct.name},");
    buf.writeln("guessed: ${guessed.name},");
    buf.writeln("count: ${count},");
    return buf.toString();
  }
}

class GenderStat implements Comparable<GenderStat> {
  final Article a;
  int good;
  int fail;
  GenderStat(this.a, this.good, this.fail);

  int get total => (good+fail);
  int get perc => total > 0 ? (100*good/total).round() : 0;

  @override
  int compareTo(GenderStat other) {
    if (a != other.a) {
      return Enum.compareByIndex(a, other.a);
    }
    return 0;
  }

  void add(final HistoryEntry h) {
    good += h.goods.length;
    fail += h.fails.length;
  }

  String toString() {
    final buf = StringBuffer();
    buf.writeln("a: ${a.name},");
    buf.writeln("good: ${good},");
    buf.writeln("fail: ${fail},");
    return buf.toString();
  }
}

class GenderGameStatCalc {
  final List<DEntry> entries;
  final List<HistoryEntry> hentries;
  GenderGameStatCalc(int take_cnt, final Dictionary d, final GenderGameHistory h):
    entries = h.allWordsByRank()
               .map<DEntry>((k) => d.byWord(k.$1, k.$2))
               .take(take_cnt)
               .toList(growable: false),
    hentries = h.allHistoriesByRank()
                .take(take_cnt)
                .toList(growable: false);
  
  List<BadGuess> countMissGuesses() {
    final Map<(Article, Article), int> miss_guesses = {};
    for (final (i,h) in hentries.indexed) {
      final e = entries[i];
      final a = e.articles.isEmpty? Article.Unknown : e.articles[0];
      for (final g in h.guess) {
        miss_guesses.update((a, g), (int v) => v+1, ifAbsent: () => 1);
      }
    }
    final result = miss_guesses.entries.map<BadGuess>((kv) => BadGuess(kv.key.$1, kv.key.$2, kv.value))
                                       .toList(growable: false);
    result.sort();
    return result;
  }

  List<GenderStat> countMissGenders() {
    final Map<Article, GenderStat> miss_genders = {};
    for (final (i,h) in hentries.indexed) {
      final e = entries[i];
      final a = e.articles.isEmpty? Article.Unknown : e.articles[0];
      final gs = miss_genders.putIfAbsent(a, () => GenderStat(a, 0, 0));
      gs.add(h);
    }
    final result = miss_genders.values.toList(growable: false);
    result.sort();
    return result;
  }
}

