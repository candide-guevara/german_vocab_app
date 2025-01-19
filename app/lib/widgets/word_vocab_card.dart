import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/dictionary_loader.dart';
import 'package:german_vocab_app/backend/vocab_game_state.dart';
import 'package:german_vocab_app/backend/utils.dart';
import 'package:german_vocab_app/widgets/open_web_content.dart';

class WordVocabCard extends StatelessWidget {
  final VocabGameState state;
  final ValueNotifier<bool?> correct;
  const WordVocabCard(this.state, this.correct, {super.key});

  String get word => state.cur_entry.word;
  String get article_str => state.cur_entry.articles.isEmpty ? "" : state.cur_entry.articles[0].name;
  int get hidx => state.cur_entry.meaning_idx;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // cardTheme.shape looks null so we cannot inherit default values?
    final CardThemeData cardTheme = Theme.of(context).cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isDarkMode ? Colors.teal.shade500 : Colors.lightGreen.shade600,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    final backNull = isDarkMode ? Colors.teal.shade900 : Colors.lightGreen.shade800;
    final backGood = isDarkMode ? Colors.teal.shade700 : Colors.lightGreen.shade700;
    final backFail = isDarkMode ? Colors.orange.shade900 : Colors.red.shade500;

    return ListenableBuilder(
      listenable: correct,
      builder: (ctx,_) => Card(
        child: buildCardContents(context),
        color: correct.value == null ? backNull : (correct.value!? backGood:backFail),
        elevation: 10,
        shape: cardTheme.shape,),
    );
  }

  Widget buildCardContents(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final double fontSize = defStyle.fontSize! * (word.length > 21 ? 21.0/word.length : 1.0);
    final word_and_idx = hidx > 1 ? "${article_str} ${word} [${hidx}]" : "${article_str} ${word}";

    final cardText = Padding(
      child: Text(
        word_and_idx,
        style: defStyle.copyWith(fontSize: fontSize),),
      padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
    );
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          cardText,
          buildWebLinks(context),
        ],
    );
  }

  Widget buildWebLinks(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.labelLarge ?? const TextStyle();
    final textStyle = defStyle.copyWith(color: Colors.blue.shade600);
    final deepl_button = TextButton(
      onPressed: buildCallDeepLCb(context, word),
      child: Text(
        'translation',
        style: textStyle),
    );
    final dwds_button = TextButton(
      onPressed: buildOpenWebViewCb(
        context,
        word,
        DictionaryLoader.d.wordUrl(state.cur_entry)),
      child: Text(
        'definition',
        style: textStyle),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,12,8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[deepl_button, dwds_button]),
    );
  }
}


