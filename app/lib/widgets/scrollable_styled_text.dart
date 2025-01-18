import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
      child: text_spans,
      scrollDirection: Axis.vertical,
    );
  }
}

