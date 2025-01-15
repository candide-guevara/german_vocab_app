import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/gender_game_state.dart';

class ProgressBar extends StatelessWidget {
  static final double kHeight = 24;
  final int word_cnt;
  final ValueNotifier<int> good_cnt;
  final ValueNotifier<int> fail_cnt;

  ProgressBar(this.word_cnt, this.good_cnt, this.fail_cnt,
              {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListenableBuilder(
          listenable: Listenable.merge([good_cnt, fail_cnt]),
          builder: (ctx, child) => buildBar(ctx, constraints.maxWidth));
      },
    );
  }

  Widget buildBar(BuildContext context, double width) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double red_width = width * (good_cnt.value+fail_cnt.value) / word_cnt;
    final double grn_width = width * good_cnt.value / word_cnt;
    //print("width:${width}, red_width:${red_width}, grn_width:${grn_width}");
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(width:width, height:kHeight),
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
        ),
        Container(
          constraints: BoxConstraints.tightFor(width:red_width, height:kHeight),
          color: isDarkMode ? Colors.red.shade600 : Colors.red,
        ),
        Container(
          constraints: BoxConstraints.tightFor(width:grn_width, height:kHeight),
          color: isDarkMode ? Colors.green.shade600 : Colors.green,
        ),
      ],);
  }
}

