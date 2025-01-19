import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'backend/dictionary_loader.dart';
import 'backend/game_history_loader.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';

class VocabGameHistoryPage extends StatelessWidget {
  static const String kPageTitle = "VocabGameHistory";

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
    if(past_games.length < 1) {
      return CenterColumn(
        children: <Widget>[ const Text("No previous games"), ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Row(),
        //Expanded(flex:2, child: PastGamesTable(kMaxPastGameRows, past_games)),
        //const Divider(),
        //Expanded(flex:3, child: ScrollableStyledText(richTextFailedWords(context))),
      ],
    );
  }
}

