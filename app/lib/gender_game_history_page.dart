import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/game_history_loader.dart';
import 'backend/gender_game_stat_calculator.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/past_games_table.dart';
import 'widgets/scrollable_styled_text.dart';

class GenderGameHistoryPage extends StatelessWidget {
  static const String kPageTitle = "GenderGameHistory";
  static const int kMaxFailedWords = 300;
  static final Map<Article, Color> kPalette = {
    Article.der: Colors.cyan.shade600,
    Article.die: Colors.indigo.shade300,
    Article.das: Colors.purple.shade400,
  };

  Future<bool> loadConfAndGame() async {
    await DictionaryLoader.isLoaded();
    await GenderGameHistoryLoader.isLoaded();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
      body: myFutureBuilder<bool>(
        loadConfAndGame(),
        'Loading game history ...',
        builderAfterLoad,
      ),
    );
  }

  List<(String, TextStyle)> richTextFailedWords(BuildContext context, List<DEntry> fail_words, Article a) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final failStyle = defStyle.copyWith(color: kPalette[a]);
    // BE CAREFUL IT IS A TRAP!
    // Type inference implementation in dart is cr*p (contrary to C#)
    // Which means that most map functions have type (dynamic) => dynamic
    // The compiler cannot call the extension functions since it does not the type.
    // In this particular case, the `name` getter on enums is an extension.
    // This is why we need all the type hints and a dedicated method for this to work...
    final to_string = (DEntry e) => "${e.articles[0].name.toUpperCase()}  ${e.word}";
    final fail_str = fail_words.where((e) => e.articles.isNotEmpty && e.articles[0] == a)
                               .map<String>(to_string)
                               .join('\n');
    return <(String, TextStyle)>[
      (fail_str, failStyle),
    ];
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    final past_games = GenderGameHistoryLoader.h.past_games.toList();
    final fail_words = GenderGameHistoryLoader.h.failWordsByRank()
                                                .map<DEntry>((k) => DictionaryLoader.d.byWord(k.$1, k.$2))
                                                .take(kMaxFailedWords)
                                                .toList(growable: false);
    if(past_games.length < 1) {
      return CenterColumn(
        children: <Widget>[ const Text("No previous games"), ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Expanded(flex:5, child: PastGamesTable(past_games)),
        const Divider(height: 3, thickness: 3),
        Expanded(flex:9,
          child: SingleChildScrollView(
            child: Row(
              children: <Widget>[
                ScrollableStyledText(richTextFailedWords(context, fail_words, Article.der)),
                const VerticalDivider(),
                ScrollableStyledText(richTextFailedWords(context, fail_words, Article.die)),
                const VerticalDivider(),
                ScrollableStyledText(richTextFailedWords(context, fail_words, Article.das)),],),
            scrollDirection: Axis.horizontal,),
        ),
        OutlinedButton(
          child: const Text('Even More Stats!'),
          onPressed: () => showStatsDialog(context),),
      ],
    );
  }

  void showStatsDialog(final BuildContext context) {
    final TextStyle titStyle = Theme.of(context).textTheme.titleMedium ?? const TextStyle();
    final TextStyle defStyle = (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(fontFamily: "monospace");
    final TextStyle goodStyle = defStyle.copyWith(color: Colors.green.shade600);
    final TextStyle failStyle = defStyle.copyWith(color: Colors.red.shade600);

    final calc = GenderGameStatCalc(kMaxFailedWords, DictionaryLoader.d, GenderGameHistoryLoader.h);
    final List<(String, TextStyle)> style_text = [];

    for (final bg in calc.countMissGuesses()) {
      style_text.add((bg.correct.name, goodStyle));
      style_text.add((" -> ", defStyle));
      style_text.add((bg.guessed.name, failStyle));
      style_text.add((" = ${bg.count}\n", defStyle));
    }
    style_text.add(("\n", defStyle));
    for (final gs in calc.countMissGenders()) {
      style_text.add(("${gs.a.name}: ${gs.perc}% / ${gs.total}\n", defStyle));
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('More Stats', style: titStyle),
          content: ScrollableStyledText(style_text),
          actions: [
            TextButton(
              onPressed: () { Navigator.of(ctx).pop(); },
              child: const Text('Close'),
            ),
          ],
       );
    });
  }
}

