import 'package:flutter/material.dart';
import '../backend/utils.dart';

class ArticleChoice extends StatefulWidget {
  final ValueChanged<Article> onSelectionChanged;
  const ArticleChoice({super.key, required this.onSelectionChanged});

  @override
  State<ArticleChoice> createState() => _ArticleChoiceState();
}

class _ArticleChoiceState extends State<ArticleChoice> {
  ButtonSegment<Article> buildButton(Article a) {
    final String name = "${a.name[0].toUpperCase()}${a.name.substring(1)}";
    return ButtonSegment<Article>(
        value: Article.der,
        label: Text(name),
      );
  }
  
  @override
  Widget build(BuildContext context) {
   final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
   final Color borderColor = Theme.of(context).colorScheme.outline;
   final TextStyle defaultTextStyle = Theme.of(context)
        .textTheme
        .labelLarge ?? // Default style for buttons
        const TextStyle();
   final textStyle = defaultTextStyle.copyWith(fontWeight: FontWeight.bold);

    return SegmentedButton<Article>(
      segments: <ButtonSegment<Article>>[
        buildButton(Article.der),
        buildButton(Article.die),
        buildButton(Article.das),
      ],
      emptySelectionAllowed: true,
      selected: <Article>{},
      onSelectionChanged: (Set<Article> newSelection) {
        setState(() { widget.onSelectionChanged(newSelection.first); });
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.lightBlue,
        side: BorderSide(width: 3, color: borderColor),
        textStyle: textStyle,
      ),
    );
  }
}

