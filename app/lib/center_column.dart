import 'package:flutter/material.dart';

class CenterColumn extends StatelessWidget {
  final List<Widget> children;
  const CenterColumn({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return buildColumn(constraints.maxWidth * 0.04,
                           constraints.maxHeight * 0.02);
      }
    );
  }

  Widget buildColumn(double lRMargin, double spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(lRMargin, 0, lRMargin, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: children,
        ),
    ));
  }
}

