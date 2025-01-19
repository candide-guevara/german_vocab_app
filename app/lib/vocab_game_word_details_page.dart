import 'package:flutter/material.dart';
import 'backend/dictionary_entry.dart';
import 'widgets/center_column.dart';
import 'widgets/corpus_text.dart';
import 'widgets/future_builder.dart';

class VocabGameDetailsPage extends StatelessWidget {
  static const String kPageTitle = "VocabWordDetails";
  final DEntry entry;
  VocabGameDetailsPage(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    final fetch_signal = ValueNotifier<int>(0);
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
      body: Padding(
        padding: EdgeInsets.fromLTRB(12,4,12,24),
        child: CorpusText(entry, fetch_signal),),
    );
  }
}

