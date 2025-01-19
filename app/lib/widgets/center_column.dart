import 'package:flutter/material.dart';

class CenterColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment align;
  const CenterColumn({super.key,
                      required this.children,
                      this.align = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return buildColumn(constraints.maxWidth * 0.04,
                           constraints.maxHeight * 0.01);
      }
    );
  }

  Widget buildColumn(double lRMargin, double spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(lRMargin, 0, lRMargin, 0),
        child: Column(
          mainAxisAlignment: align,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: children,
        ),
    ));
  }
}

