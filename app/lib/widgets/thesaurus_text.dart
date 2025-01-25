import 'package:flutter/material.dart';
import 'package:german_vocab_app/backend/dictionary_entry.dart';
import 'package:german_vocab_app/backend/thesaurus_rest.dart';
import 'package:german_vocab_app/widgets/future_builder.dart';
import 'package:german_vocab_app/widgets/scrollable_styled_text.dart';

class ThesaurusText extends StatelessWidget {
  final String word;
  const ThesaurusText(this.word, {super.key});

  @override
  Widget build(BuildContext context) {
    return myFutureBuilder<Thesaurus>(
      fetchThesaurusFor(word),
      'Loading thesaurus for "${word}" ...',
      buildThesaurusText,
    );
  }

  Widget buildThesaurusText(BuildContext context, Thesaurus thesaurus) {
    final TextStyle defStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final TextStyle hiStyle = defStyle.copyWith(fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade600,);
    if (thesaurus.synsets.isEmpty) { return Text("No synonyms found"); }
    final List<(String, TextStyle)> data = [];
    for (final (idx,synset) in thesaurus.synsets.indexed) {
      data.add((synset.join(', '), defStyle));
      data.add(('\n\n', defStyle));
    }
    data.removeLast();
    return ScrollableStyledText(data);
  }
}


