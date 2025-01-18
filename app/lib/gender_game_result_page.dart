import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/gender_game_state.dart';
import 'widgets/center_column.dart';
import 'widgets/scrollable_styled_text.dart';

class GenderGameResultPage extends StatelessWidget {
  static const String kPageTitle = "GenderGame results";
  final GenderGameState state;

  GenderGameResultPage(this.state, {super.key});

  List<DEntry> sortedEntries(final Iterable<DEntry> entries) {
    final sorted_entries = entries.toList();
    sorted_entries.sort((e1,e2) => e1.word.compareTo(e2.word));
    return sorted_entries;
  }

  List<(String, TextStyle)> richTextFromGameWords(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final failStyle = defStyle.copyWith(color: Colors.red.shade600,
                                        fontFamily: 'monospace');
    final goodStyle = defStyle.copyWith(color: Colors.green.shade600,
                                        fontFamily: 'monospace');
    final fail_words = sortedEntries(state.fail).map((e) => "${e.articles[0].name.toUpperCase()}   ${e.word}")
                                                .join('\n');
    final good_words = sortedEntries(state.good).map((e) => "${e.articles[0].name.toUpperCase()}   ${e.word}")
                                                .join('\n');
    return <(String, TextStyle)>[
      (fail_words, failStyle),
      ('\n  \n', defStyle),
      (good_words, goodStyle),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium ?? const TextStyle();
    final int perc = (100 * state.good.length / state.game.length).round();
    final String title = "Success rate: ${perc}%";
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
      body: CenterColumn(
        children: <Widget>[
          const Divider(),
          Text(title, style: titleStyle),
          Expanded(child: ScrollableStyledText(richTextFromGameWords(context))),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
            child: const Divider(),),
        ],
      ),
    );
  }
}

