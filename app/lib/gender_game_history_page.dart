import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/gender_game_history_loader.dart';
import 'backend/gender_game_state.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/scrollable_styled_text.dart';

class GenderGameHistoryPage extends StatelessWidget {
  static const String kPageTitle = "GameHistory";
  static const int kMaxFailedWords = 20;
  static const int kMaxPastGameRows = 10;

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

  List<(String, TextStyle)> richTextFailedWords(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final failStyle = defStyle.copyWith(color: Colors.red.shade600,
                                        fontFamily: 'monospace');
    // BE CAREFUL IT IS A TRAP!
    // Type inference implementation in dart is cr*p (contrary to C#)
    // Which means that most map functions have type (dynamic) => dynamic
    // The compiler cannot call the extension functions since it does not the type.
    // In this particular case, the `name` getter on enums is an extension.
    // This is why we need all the type hints and a dedicated method for this to work...
    final to_string = (DEntry e) => "${e.articles[0].name.toUpperCase()}   ${e.word}";
    final fail_words = GenderGameHistoryLoader.h.failWordsByRank()
                                                .take(kMaxFailedWords)
                                                .map<DEntry>((k) => DictionaryLoader.d.byWord(k.$1, k.$2))
                                                .map<String>(to_string)
                                                .join('\n');
    return <(String, TextStyle)>[
      ("Most failed", Theme.of(context).textTheme.titleLarge ?? const TextStyle()),
      ("\n\n", failStyle),
      (fail_words, failStyle),
    ];
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    final past_games = GenderGameHistoryLoader.h.past_games.toList();
    if(past_games.length < 1) {
      return CenterColumn(
        children: <Widget>[ const Text("No previous games"), ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Expanded(flex:2, child: PastGamesTable(kMaxPastGameRows, past_games)),
        const Divider(),
        Expanded(flex:3, child: ScrollableStyledText(richTextFailedWords(context))),
      ],
    );
  }
}

class PastGamesTable extends StatelessWidget {
  final int max_rows;
  final List<PastGame> past_games;
  PastGamesTable(this.max_rows, this.past_games, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle rowStyle = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final totStyle = (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                   .copyWith(fontWeight: FontWeight.bold);
    final formatter = (DateTime dt) {
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '${dt.year}-${m}-${d}';
    };
    final tot_count = past_games.fold(0, (a,g) => a + g.good)
                    + past_games.fold(0, (a,g) => a + g.fail);
    final tot_perc = (100 * past_games.fold(0, (a,g) => a + g.good) / tot_count).round();
    final rows = past_games.take(max_rows).map((pg) {
      int perc = (100 * pg.good / pg.word_cnt).round();
      return DataRow(cells: [
        DataCell(Text(formatter(pg.date))),
        DataCell(Text('${perc}%')),
        DataCell(Text('${pg.word_cnt}')),
      ]);
    }).toList();
    rows.add(
      DataRow(cells: [
        DataCell(Text("Total", style:totStyle)),
        DataCell(Text('${tot_perc}%', style:totStyle)),
        DataCell(Text('${tot_count}', style:totStyle)),
      ])
    );
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        dataRowMinHeight: 28,
        dataRowMaxHeight: 36,
        dataTextStyle: rowStyle,
        columns: [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Success')),
          DataColumn(label: Text('Count')),
        ],
        rows: rows,
      ),
    );
  }
}

