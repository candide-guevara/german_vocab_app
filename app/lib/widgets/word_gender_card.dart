import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/dictionary_loader.dart';
import 'package:german_vocab_app/backend/gender_game_state.dart';
import 'package:german_vocab_app/backend/utils.dart';
import 'package:german_vocab_app/widgets/open_web_content.dart';

class WordGenderCard extends StatelessWidget {
  final GenderGameState state;
  final ValueNotifier<bool?> correct;
  const WordGenderCard({super.key,
                        required this.state,
                        required this.correct});

  String get word => state.cur_entry.word;
  String get article_str => state.cur_entry.first_a().name;
  int get hidx => state.cur_entry.meaning_idx;

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

    final buildCardText = (BuildContext ctx, Widget? _) {
      final double fontSize = defStyle.fontSize! * (word.length > 21 ? 21.0/word.length : 1.0);
      final word_and_idx = hidx > 1 ? "${word} [${hidx}]" : word;
      return Padding(
        child: Text(
          word_and_idx,
          style: defStyle.copyWith(fontSize: fontSize),),
        padding: EdgeInsets.fromLTRB(16, 8, 0, 12),
      );
    };
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListenableBuilder(
            listenable: correct,
            builder: buildCardIcon,),
          ListenableBuilder(
            listenable: correct,
            builder: buildCardText,),
          // Ideally we should refresh the links only when changing words
          // (aka when `correct` transitions to null)
          ListenableBuilder(
            listenable: correct,
            builder: (ctx,_) => buildWebLinks(ctx),),
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
      padding: EdgeInsets.fromLTRB(0,0,12,16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[deepl_button, dwds_button]),
    );
  }

  Widget buildCardIcon(BuildContext ctx, Widget? _) {
    final TextStyle defStyle = Theme.of(ctx).textTheme.titleLarge ?? const TextStyle();
    Widget? icon;
    if(correct.value == null) {
      icon = Icon(Icons.question_mark_rounded, color: Colors.grey, size: 42,);
    }
    else if(correct.value!) {
      final textStyle = defStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold);
      icon = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(Icons.thumb_up, color: Colors.green, size: 42,),
          Text(article_str, style: textStyle),
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
          Text(article_str, style: textStyle),
        ],
      );
    }
    return Padding( 
      child: icon,
      padding: EdgeInsets.fromLTRB(16,12,24,8),
    );
  }
}

