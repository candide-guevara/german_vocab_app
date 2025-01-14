import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/gender_game_config.dart';
import 'backend/gender_game_state.dart';
import 'backend/gender_game_state_loader.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/article_choice.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/progress_bar.dart';
import 'widgets/word_gender_card.dart';

class GenderGame extends StatelessWidget {
  static const String kPageTitle = "GenderGame";
  final ValueNotifier<bool?> cur_correct;
  final ValueNotifier<bool> disable_cb;
  final ValueNotifier<int> cur_index;
  final ValueNotifier<int> good_cnt;
  final ValueNotifier<int> fail_cnt;
  final List<DEntry> game;
  final GenderGameState state;
  final GenderGameConfig conf;

  GenderGame({super.key}):
    cur_correct = ValueNotifier<bool?>(null),
    disable_cb = ValueNotifier<bool>(false),
    cur_index = ValueNotifier<int>(0),
    good_cnt = ValueNotifier<int>(0),
    fail_cnt = ValueNotifier<int>(0),
    game = <DEntry>[],
    state = GenderGameState(),
    conf = GenderGameConfig.def();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: myFutureBuilder<bool>(
        loadConfAndGame(),
        'Loading dictionary ...',
        builderAfterLoad,
      ),
    );
  }

  Future<bool> loadConfAndGame() async {
    await Future.wait([
      DictionaryLoader.isLoaded(),
      Persistence.isLoaded(),
      GenderGameHistoryLoader.isLoaded(),
    ]);
    conf.setFrom(await GenderGameConfig.load());
    game.clear();
    game.addAll(DictionaryLoader.d.sampleGameWords(conf));
    return true;
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    return CenterColumn(
      children: <Widget>[
        ProgressBar(
          conf.word_cnt, good_cnt, fail_cnt),
        ListenableBuilder(
          listenable: cur_correct,
          builder: (ctx, child) => WordGenderCard(
            word: game[cur_index.value].word,
            expected_article: game[cur_index.value].articles[0],
            is_correct: cur_correct.value),
        ),
        ArticleChoice(
          onSelectionChanged: onArticleSelected),
      ],
    );
  }

  void onArticleSelected(Article a) async {
    if (disable_cb.value) { return; }
    disable_cb.value = true;
    cur_correct.value = game[cur_index.value].articles[0] == a;
    state.add(game[cur_index.value], cur_correct.value!);
    good_cnt.value += cur_correct.value! ? 1 : 0;
    fail_cnt.value += cur_correct.value! ? 0 : 1;

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if(cur_index.value < game.length - 1) {
      cur_index.value++;
      cur_correct.value = null;
      disable_cb.value = false;
    }
    else {
      GenderGameHistoryLoader.h.appendFinishedGame(state);
      GenderGameHistoryLoader.save();
    }
  }
}

