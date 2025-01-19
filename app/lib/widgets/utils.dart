import 'package:flutter/material.dart';

double getTextHeight(TextStyle textStyle) {
  final textPainter = TextPainter(
    text: TextSpan(text: 'A', style: textStyle),
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size.height;
}

