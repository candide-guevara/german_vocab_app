import 'package:flutter/material.dart';
import 'backend/dictionary_loader.dart';
import 'backend/gender_game_config.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';
import 'widgets/article_choice.dart';
import 'widgets/word_gender_card.dart';

class GenderGame extends StatelessWidget {
  static const String kPageTitle = "GenderGame";
  const GenderGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: FutureBuilder(
        future: DictionaryLoader.isLoaded(),
        builder: builderAfterLoad,
      ),
    );
  }

  Widget builderAfterLoad(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.hasData) {
      //String word = "Bundesverfassungsgericht0123";
      //String word = "Bundesverfassung1234567";
      //String word = "Bundesverfassung";
      //String word = DictionaryLoader.d.byIdx(666).word;
      final conf = GenderGameConfig(10);
      final words = DictionaryLoader.d.sampleGameWords(conf);
      String word = words[0].word;
      var state = WordGenderState(word);
      return CenterColumn(
        children: <Widget>[
          WordGenderCard(state: state),
          ArticleChoice(onSelectionChanged: (Article a){}),
        ],
      );
    }
    if (snapshot.hasError) {
      return CenterColumn(
        children: <Widget>[
          const Icon( Icons.error_outline, color: Colors.red, size: 60,),
          Padding( padding: const EdgeInsets.only(top: 16), child: Text('Error: ${snapshot.error}'),),
        ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Text(
          'Loading Dictionary...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        CircularProgressIndicator(semanticsLabel: "Loading Dictionary..."),
      ],
    );
  }

}

