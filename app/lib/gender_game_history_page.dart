import 'package:flutter/material.dart';
import 'backend/gender_game_history_loader.dart';
import 'backend/gender_game_state.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';

class GenderGameHistoryPage extends StatelessWidget {
  static const String kPageTitle = "GameHistory";

  Future<bool> loadConfAndGame() async {
    await GenderGameHistoryLoader.isLoaded();
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
    final past_games = GenderGameHistoryLoader.h.past_games.toList();
    return CenterColumn(
      children: <Widget>[
        Expanded(child: PastGamesTable(past_games)),
      ],
    );
  }
}

class PastGamesTable extends StatelessWidget {
  static final int kMaxRows = 10;
  final List<PastGame> past_games;
  PastGamesTable(this.past_games, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle rowStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final formatter = (DateTime dt) {
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '${dt.year}-${m}-${d}';
    };
    final rows = past_games.take(kMaxRows).map((pg) {
      int perc = (100 * pg.good / pg.word_cnt).round();
      return DataRow(cells: [
        DataCell(Text(formatter(pg.date), style:rowStyle)),
        DataCell(Text('${perc}%', style:rowStyle)),
        DataCell(Text('${pg.word_cnt}', style:rowStyle)),
      ]);
    }).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Success')),
          DataColumn(label: Text('Count')),
        ],
        rows: rows,
      ),
    );
  }
}

