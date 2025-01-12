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
    final notify_correct = ValueNotifier<bool?>(null);
    final notify_index = ValueNotifier<int>(0);
    final disable_cb = ValueNotifier<bool>(false);
    final card = ListenableBuilder(
      listenable: notify_correct,
      builder: (ctx, child) => WordGenderCard(
        word: game[notify_index.value].word,
        expected_article: game[notify_index.value].articles[0],
        is_correct: notify_correct.value),
    );
    return CenterColumn(
      children: <Widget>[
        card,
        ArticleChoice(onSelectionChanged: (Article a) async {
          if (disable_cb.value) { return; }
          disable_cb.value = true;
          notify_correct.value = game[notify_index.value].articles[0] == a;
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if(notify_index.value < game.length - 1) {
            notify_index.value++;
            notify_correct.value = null;
          }
          disable_cb.value = false;
        }),
      ],
    );
  }
}

