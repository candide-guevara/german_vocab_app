import 'package:flutter/material.dart';
import '../backend/utils.dart';

class WordGenderCard extends StatelessWidget {
  final String word;
  final Article expected_article;
  final bool? is_correct;
  const WordGenderCard({super.key,
                        required this.word,
                        required this.expected_article,
                        required this.is_correct});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // cardTheme.shape looks null so we cannot inherit default values?
    final CardThemeData cardTheme = Theme.of(context).cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isDarkMode ? Colors.blueGrey.shade500 : Colors.lightBlue.shade600,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Card(
      child: buildCardContents(context),
      color: isDarkMode ? Colors.blueGrey.shade900 : Colors.lightBlue.shade800,
      elevation: 10,
      shape: cardTheme.shape,
    );
  }

  Widget buildCardContents(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final double fontSize = defStyle.fontSize! * (word.length > 21 ? 21.0/word.length : 1.0);

    final cardText = Padding( 
      child: Text(
        word,
        style: defStyle.copyWith(fontSize: fontSize),
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 0, 24),
    );
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildCardIcon(context),
          cardText,
        ],
    );
  }

  Widget buildCardIcon(BuildContext ctx) {
    final TextStyle defStyle = Theme.of(ctx).textTheme.titleLarge ?? const TextStyle();
    Widget? icon;
    if(is_correct == null) {
      icon = Icon(Icons.question_mark_rounded, color: Colors.grey, size: 42,);
    }
    else if(is_correct!) {
      final textStyle = defStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold);
      icon = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(Icons.thumb_up, color: Colors.green, size: 42,),
          Text("${expected_article.name}", style: textStyle),
        ],
      );
    }
    else {
      final textStyle = defStyle.copyWith(color: Colors.red, fontWeight: FontWeight.bold);
      icon = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Transform.flip(
            flipX: true,
            child: Icon(Icons.thumb_down, color: Colors.red, size: 42,),
          ),
          Text("${expected_article.name}", style: textStyle),
        ],
      );
    }
    return Padding( 
      child: icon,
      padding: EdgeInsets.fromLTRB(16,12,24,8),
    );
  }
}


