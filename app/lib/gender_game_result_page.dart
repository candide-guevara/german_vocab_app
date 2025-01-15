import 'package:flutter/material.dart';
import 'backend/gender_game_state.dart';
import 'widgets/center_column.dart';

class GenderGameResultPage extends StatelessWidget {
  static const String kPageTitle = "GenderGame results";
  final GenderGameState state;

  GenderGameResultPage(this.state, {super.key});

  List<(String, TextStyle)> richTextFromGameWords(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final failStyle = defStyle.copyWith(color: Colors.red.shade600,
                                        fontFamily: 'monospace');
    final goodStyle = defStyle.copyWith(color: Colors.green.shade600,
                                        fontFamily: 'monospace');
    final fail_words = state.bad.map((e) => "${e.articles[0].name.toUpperCase()}   ${e.word}")
                                .join('\n');
    final good_words = state.good.map((e) => "${e.articles[0].name.toUpperCase()}   ${e.word}")
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
          ScrollableStyledText(richTextFromGameWords(context)),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
            child: const Divider(),),
        ],
      ),
    );
  }
}

class ScrollableStyledText extends StatelessWidget {
  final List<(String, TextStyle)> text_and_style;

  ScrollableStyledText(this.text_and_style, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = text_and_style.map((kv) {
      final (msg, style) = kv;
      return TextSpan(text: msg, style: style);
    }).toList();

    final text_spans = RichText(
      text: TextSpan(
        children: spans,
        style: DefaultTextStyle.of(context).style,),
    );
    return Expanded(child: SingleChildScrollView(
      child: text_spans,
      scrollDirection: Axis.vertical,
    ));
  }
}

