import 'package:flutter/material.dart';
import 'gender_game_result_page.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/game_config.dart';
import 'backend/gender_game_state.dart';
import 'backend/game_history_loader.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/article_choice.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/progress_bar.dart';
import 'widgets/word_gender_card.dart';

class GenderGamePage extends StatelessWidget {
  static const String kPageTitle = "GenderGame";
  final ValueNotifier<bool?> cur_correct;
  final ValueNotifier<bool> disable_cb;
  final ValueNotifier<int> good_cnt;
  final ValueNotifier<int> fail_cnt;
  final GenderGameState state;
  final GenderGameConfig conf;

  GenderGamePage({super.key}):
    cur_correct = ValueNotifier<bool?>(null),
    disable_cb = ValueNotifier<bool>(false),
    good_cnt = ValueNotifier<int>(0),
    fail_cnt = ValueNotifier<int>(0),
    state = GenderGameState(),
    conf = GenderGameConfig.def();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
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
    state.setWords(
      DictionaryLoader.d.sampleGameWords(conf, GenderGameHistoryLoader.h));
    return true;
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    return CenterColumn(
      align: MainAxisAlignment.spaceAround,
      children: <Widget>[
        ProgressBar(
          conf.word_cnt, good_cnt, fail_cnt),
        WordGenderCard(
          state: state,
          correct: cur_correct),
        ArticleChoice(
          onSelectionChanged: (a) => onArticleSelected(context, a)),
      ],
    );
  }

  void onArticleSelected(BuildContext context, Article a) async {
    if (disable_cb.value) { return; }
    disable_cb.value = true;
    cur_correct.value = state.cur_entry.articles[0] == a;
    good_cnt.value += cur_correct.value! ? 1 : 0;
    fail_cnt.value += cur_correct.value! ? 0 : 1;

    await Future<void>.delayed(const Duration(milliseconds: 700));
    state.advance(cur_correct.value!);

    if(!state.isDone) {
      cur_correct.value = null;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      disable_cb.value = false;
    }
    else {
      GenderGameHistoryLoader.h.appendFinishedGame(state);
      GenderGameHistoryLoader.save();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => GenderGameResultPage(GenderGameState.clone(state)))
      );
    }
  }
}

