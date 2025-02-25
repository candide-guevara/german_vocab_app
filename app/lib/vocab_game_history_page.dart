import 'dart:collection';
import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/dwds_corpus_rest.dart';
import 'backend/game_history_loader.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/past_games_table.dart';
import 'widgets/utils.dart';
import 'vocab_game_word_details_page.dart';

class VocabGameHistoryPage extends StatelessWidget {
  static const String kPageTitle = "VocabGameHistory";
  static const int kMaxFailedWords = 1000;

  Future<bool> loadConfAndGame() async {
    await DictionaryLoader.isLoaded();
    await VocabGameHistoryLoader.isLoaded();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
      body: myFutureBuilder<bool>(
        loadConfAndGame(),
        'Loading game history ...',
        builderAfterLoad,
      ),
    );
  }

  Iterable<DEntry?> needThisBecauseOfStupidTypeInferenceImpl() {
    return VocabGameHistoryLoader.h.failWordsByRank()
                                   .map<DEntry?>((k) => DictionaryLoader.d.byWord(k.$1, k.$2));
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    final past_games = VocabGameHistoryLoader.h.past_games.toList();
    final fail_words = needThisBecauseOfStupidTypeInferenceImpl()
                                               .nonNulls
                                               .take(kMaxFailedWords)
                                               .toList();
    if(past_games.length < 1) {
      return CenterColumn(
        children: <Widget>[ const Text("No previous games"), ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Expanded(flex:5, child: PastGamesTable(past_games)),
        const Divider(height: 3, thickness: 3),
        Expanded(flex:9, child: MostFailedList(fail_words)),
      ],
    );
  }
}

class MostFailedList extends StatelessWidget {
  final Map<PosType, Color> kPalette = {
    PosType.Substantiv: Colors.grey.shade400,
    PosType.Adverb:     Colors.cyan.shade600,
    PosType.Adjektiv:   Colors.indigo.shade400,
    PosType.Verb:       Colors.lime.shade600,
    PosType.Unknown:    Colors.purple.shade600,
  };
  final List<DEntry> words;
  MostFailedList(this.words, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final textHeight = getTextHeight(defStyle);
    final colorStyles = kPalette.values.map((c) => defStyle.copyWith(color:c)).toList();
    final pos_palette = Map<PosType, TextStyle>.fromEntries(
      words.map((w) => w.pos).toSet().map((p) {
        final style = defStyle.copyWith(color: kPalette[p] ?? kPalette[PosType.Unknown]);
        return MapEntry(p, style);
      })
    );
    final pos_icon = Map<PosType, Icon>.fromEntries(
      words.map((w) => w.pos).toSet().map((p) {
        final icon = Icon(
          Icons.manage_search,
          size: 0.9*textHeight,
          color: kPalette[p] ?? kPalette[PosType.Unknown],);
        return MapEntry(p, icon);
      })
    );

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final title = word.articles.isEmpty? word.word : "${word.articles[0].name} ${word.word}";
        return ListTile(
          key: UniqueKey(),
          title: Text(title),
          dense: true,
          leading: pos_icon[word.pos],
          titleTextStyle: pos_palette[word.pos],
          contentPadding: EdgeInsets.fromLTRB(8,0,0,0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => VocabGameDetailsPage(word)));
          },
        );
      },
      itemExtent: textHeight + 6,
      padding: EdgeInsets.fromLTRB(0,0,0,0),
    );
  }
}

