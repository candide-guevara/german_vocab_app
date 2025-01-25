import 'package:flutter/material.dart';
import '../backend/utils.dart';

class ArticleChoice extends StatelessWidget {
  final ValueChanged<Article> onSelectionChanged;
  const ArticleChoice({super.key, required this.onSelectionChanged});

  @override
  Widget build(BuildContext context) {
   final Color borderColor = Theme.of(context).colorScheme.outline;
   final defStyle = Theme.of(context).filledButtonTheme.style ?? ButtonStyle();
   final buttonStyle = defStyle.copyWith(
     side: MaterialStateProperty.resolveWith<BorderSide>((s) => BorderSide(color: borderColor, width: 2))
   );

    return Row(
      children: [
        buildButton(Article.der, buttonStyle),
        buildButton(Article.die, buttonStyle),
        buildButton(Article.das, buttonStyle),
      ],
    );
  }

  Widget buildButton(Article a, ButtonStyle buttonStyle) {
    final String name = "${a.name[0].toUpperCase()}${a.name.substring(1)}";
    return Expanded(child: OutlinedButton(
      child: Text(name),
      onPressed: () => onSelectionChanged(a),
      style: buttonStyle,
    ));
  }
}

