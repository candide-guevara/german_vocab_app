import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
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
      body: myFutureBuilder<(List<DEntry>,GenderGameConfig)>(
        loadConfAndGame(),
        'Loading dictionary ...',
        builderAfterLoad,
      ),
    );
  }

  Future<(List<DEntry>,GenderGameConfig)> loadConfAndGame() async {
    await Future.wait([
      DictionaryLoader.isLoaded(),
      Persistence.isLoaded(),
    ]);
    final conf = await GenderGameConfig.load();
    final game = DictionaryLoader.d.sampleGameWords(conf);
    return (game, conf);
  }

  Widget builderAfterLoad(BuildContext context,
                          (List<DEntry>,GenderGameConfig) record) {
    final (game, conf) = record;
    var state = WordGenderState(game[0].word);
    return CenterColumn(
      children: <Widget>[
        WordGenderCard(state: state),
        ArticleChoice(onSelectionChanged: (Article a){}),
      ],
    );
  }
}

