import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/gender_game_state.dart';
import 'package:german_vocab_app/widgets/utils.dart';

class PastGamesTable extends StatelessWidget {
  static const int kMaxRows = 10;
  static const int kMaxConsider = kMaxRows * 2;
  final List<PastGame> past_games;
  PastGamesTable(this.past_games, {super.key});

  Iterable<PastGame> get r_games => past_games.reversed;

  @override
  Widget build(BuildContext context) {
    final hdrStyle = DataTableTheme.of(context).headingTextStyle ?? const TextStyle();
    final rowStyle = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final totStyle = (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                   .copyWith(fontWeight: FontWeight.bold);
    final rowHeight = getTextHeight(totStyle);
    final hdrHeight = getTextHeight(hdrStyle);
    final formatter = (DateTime dt) {
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '${dt.year}-${m}-${d}';
    };
    final tot_count = r_games.take(kMaxConsider).fold(0, (a,g) => a + g.good)
                    + r_games.take(kMaxConsider).fold(0, (a,g) => a + g.fail);
    final tot_perc = (r_games.take(kMaxConsider).fold(0, (a,g) => a + g.good) * 100/ tot_count).round();
    final List<DataRow> rows = [
      DataRow(cells: [
        DataCell(Text("Total", style:totStyle)),
        DataCell(Text('${tot_perc}%', style:totStyle)),
        DataCell(Text('${tot_count}', style:totStyle)),
      ])
    ];
    rows.addAll(r_games.take(kMaxRows).map((pg) {
      int perc = (100 * pg.good / pg.word_cnt).round();
      return DataRow(cells: [
        DataCell(Text(formatter(pg.date))),
        DataCell(Text('${perc}%')),
        DataCell(Text('${pg.word_cnt}')),
      ]);
    }));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        dataRowMinHeight: rowHeight+10,
        dataRowMaxHeight: rowHeight+10,
        headingRowHeight: hdrHeight+16,
        dataTextStyle: rowStyle,
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

