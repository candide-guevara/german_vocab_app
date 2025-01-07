import 'package:flutter/material.dart';
import 'widgets/center_column.dart';
import 'widgets/article_choice.dart';
import 'widgets/word_gender_card.dart';
import 'utils.dart';

class GenderGame extends StatelessWidget {
  static const String kPageTitle = "GenderGame";
  const GenderGame({super.key});

  @override
  Widget build(BuildContext context) {
    String word = "Bundesverfassungsgericht0123";
    //String word = "Bundesverfassung1234567";
    //String word = "Bundesverfassung";
    var state = WordGenderState(word);
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: CenterColumn(
        children: <Widget>[
          WordGenderCard(state: state),
          ArticleChoice(onSelectionChanged: (Article a){}),
        ],
      ),
    );
  }
}

