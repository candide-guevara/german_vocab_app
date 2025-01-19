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
  static const int kMaxPastGameRows = 10;
  static const int kMaxFailedWords = 20;

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

  Widget builderAfterLoad(BuildContext context, bool _) {
    final past_games = VocabGameHistoryLoader.h.past_games.toList();
    final fail_words = VocabGameHistoryLoader.h.failWordsByRank()
                                               .take(kMaxFailedWords)
                                               .map<DEntry>((k) => DictionaryLoader.d.byWord(k.$1, k.$2))
                                               .toList();
    if(past_games.length < 1) {
      return CenterColumn(
        children: <Widget>[ const Text("No previous games"), ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Expanded(flex:2, child: PastGamesTable(kMaxPastGameRows, past_games)),
        const Divider(height: 3, thickness: 3),
        Expanded(flex:3, child: MostFailedList(fail_words)),
      ],
    );
  }
}

class MostFailedList extends StatelessWidget {
  final List<Color> kPalette = [
    Colors.grey.shade400,
    Colors.cyan.shade600,
    Colors.indigo.shade400,
    Colors.lime.shade600,
    Colors.purple.shade600,
  ];
  final List<DEntry> words;
  MostFailedList(this.words, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final textHeight = getTextHeight(defStyle);
    final icon = Icon(Icons.book, size: 0.8*textHeight,);
    final colorStyles = kPalette.map((c) => defStyle.copyWith(color:c)).toList();
    final pos_palette = Map<PosType, TextStyle>.fromEntries(
      words.map((w) => w.pos).toSet().indexed.map((kv) => MapEntry(kv.$2, colorStyles[kv.$1 % kPalette.length]))
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
          leading: icon,
          titleTextStyle: pos_palette[word.pos],
          contentPadding: EdgeInsets.fromLTRB(8,0,0,0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => VocabGameDetailsPage(word)));
          },
        );
      },
      itemExtent: textHeight + 4,
      padding: EdgeInsets.fromLTRB(0,0,0,0),
    );
  }
}

