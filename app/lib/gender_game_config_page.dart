import 'package:flutter/material.dart';
import 'backend/gender_game_config.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/int_slider.dart';
import 'widgets/labelled_switch.dart';

class GenderGameConfigPage extends StatelessWidget {
  static const String kPageTitle = "GenderGameConfig";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: myFutureBuilder<GenderGameConfig>(
        Persistence.isLoaded().then( (_) => GenderGameConfig.load() ),
        'Loading preferences ...',
        builderAfterLoad,
      ),
    );
  }

  Widget builderAfterLoad(BuildContext context, GenderGameConfig g) {
    return CenterColumn(
      children: <Widget>[
        const Text('Word count per round:'),
        IntSlider(
          min: kGameRoundsMin,
          max: kGameRoundsMax,
          ini_val: g.word_cnt,
          onChanged: (v) async { g.word_cnt = v; await g.save(); }),
        const Text('Word frequency:'),
        IntSlider(
          min: kFreqMin,
          max: kFreqMax,
          ini_val: g.min_freq,
          onChanged: (v) async { g.min_freq = v; await g.save(); }),
        const Divider(),
        LabelledSwitch(
          ini_val: g.has(TagType.TrivialGender),
          label: "Ignore words with trivial gender:",
          onChanged: (v) async { g.set(TagType.TrivialGender); await g.save(); }),
        LabelledSwitch(
          ini_val: g.has(TagType.FemProfession),
          label: "Ignore feminine professions:",
          onChanged: (v) async { g.set(TagType.FemProfession); await g.save(); }),
        LabelledSwitch(
          ini_val: g.has(TagType.LikelyEnglish),
          label: "Ignore english words (approx):",
          onChanged: (v) async { g.set(TagType.LikelyEnglish); await g.save(); }),
        LabelledSwitch(
          ini_val: g.has(TagType.Funky),
          label: "Ignore funky words:",
          onChanged: (v) async { g.set(TagType.Funky); await g.save(); }),
        const Divider(),
        FilledButton(
          child: const Text("Reset config and game history"),
          onPressed: () async { },
        ),
      ],
    );
  }
}

