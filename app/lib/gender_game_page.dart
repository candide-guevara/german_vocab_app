import 'package:flutter/material.dart';
import 'backend/dictionary_loader.dart';
import 'backend/gender_game_config.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/article_choice.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/word_gender_card.dart';

class GenderGame extends StatelessWidget {
  static const String kPageTitle = "GenderGame";
  const GenderGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: myFutureBuilder<List<bool>>(
        Future.wait([
          DictionaryLoader.isLoaded(),
          Persistence.isLoaded(),
        ]),
        'Loading dictionary ...',
        builderAfterLoad,
      ),
    );
  }

  Widget builderAfterLoad(BuildContext context, List<bool> _) {
    final conf = GenderGameConfig.load();
    final game = DictionaryLoader.d.sampleGameWords(conf);
    var state = WordGenderState(game[0].word);
    return CenterColumn(
      children: <Widget>[
        WordGenderCard(state: state),
        ArticleChoice(onSelectionChanged: (Article a){}),
      ],
    );
  }
}

