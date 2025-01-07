import 'package:flutter/material.dart';
import 'home.dart';
import 'utils.dart';

void main() {
  runApp(MaterialApp(
    builder: (context, child) {
      double scaleFactor = MediaQuery.of(context).size.width / kReferenceWidth;
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scaleFactor.clamp(1.0, 1.5)),
        ),
        child: child!,
      );
    },
    home: HomePage(),
    theme: ThemeData.dark(),
    darkTheme: ThemeData.dark(),
  ));
}

