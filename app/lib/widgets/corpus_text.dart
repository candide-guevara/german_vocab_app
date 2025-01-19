import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/dwds_corpus_rest.dart';
import 'package:german_vocab_app/widgets/future_builder.dart';
import 'package:german_vocab_app/widgets/scrollable_styled_text.dart';

class CorpusText extends StatelessWidget {
  final DEntry entry;
  final ValueNotifier<int> fetch_signal;
  const CorpusText(this.entry, this.fetch_signal, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: fetch_signal,
      builder: (ctx,_) => myFutureBuilder<Corpus>(
        fetchDwdsCorpusFor(entry.word),
        'Loading corpus for "${entry.word}" ...',
        buildCorpusText,
      ),
    );
  }
  Widget buildCorpusText(BuildContext context, Corpus corpus) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final TextStyle hiStyle = defStyle.copyWith(fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade600,);
    if (corpus.sentences.isEmpty) { return Text("No corpus sentences found"); }
    final List<(String, TextStyle)> data = [];
    for (final (idx,sentence) in corpus.sentences.indexed) {
      final (start, end) = corpus.token_pos[idx];
      data.add((sentence.substring(0, start), defStyle));
      data.add((sentence.substring(start, end), hiStyle));
      data.add((sentence.substring(end), defStyle));
      data.add(('\n\n', defStyle));
    }
    data.removeLast();
    return ScrollableStyledText(data);
  }
}

