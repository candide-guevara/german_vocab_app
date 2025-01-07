import 'package:flutter/material.dart';
import '../utils.dart';

class WordGenderState with ChangeNotifier {
  String word;
  Article? article;

  WordGenderState(this.word, {this.article});

  void setWord(String w) {
    word = w;
    notifyListeners();
  }
  void setArticle(Article a) {
    article = a;
    notifyListeners();
  }
}

class WordGenderCard extends StatelessWidget {
  final WordGenderState state;
  const WordGenderCard({super.key, required this.state});

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

    return ListenableBuilder(
      listenable: state,
      builder: (BuildContext context, Widget? child) => Card(
        child: buildCardContents(context),
        color: isDarkMode ? Colors.blueGrey.shade900 : Colors.lightBlue.shade800,
        elevation: 10,
        shape: cardTheme.shape,
      ),
    );
  }

  Widget buildCardContents(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildCardIcon(),
          buildCardText(context),
        ],
    );
  }

  Widget buildCardText(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final double fontSize = defStyle.fontSize! * (state.word.length > 21 ? 21.0/state.word.length : 1.0);
    return Padding( 
      child: Text(
        state.word,
        style: defStyle.copyWith(fontSize: fontSize),
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 0, 24),
    );
  }

  Widget buildCardIcon() {
    return Padding( 
      child: Icon(
        Icons.question_mark_rounded,
        color: Colors.grey,
        size: 42,
      ),
      padding: EdgeInsets.fromLTRB(16,12,8,8),
    );
  }
}


