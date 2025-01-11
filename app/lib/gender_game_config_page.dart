import 'package:flutter/material.dart';
import 'backend/utils.dart';
import 'backend/persistence_store.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/int_slider.dart';
import 'widgets/labelled_switch.dart';

class GenderGameConfigPage extends StatelessWidget {
  static const String kPageTitle = "GenderGameConfig";
  const GenderGameConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: myFutureBuilder<bool>(
        Persistence.isLoaded(),
        'Loading preferences ...',
        builderAfterLoad,
      ),
    );
  }

  Widget builderAfterLoad(BuildContext context, bool _) {
    return CenterColumn(
      children: <Widget>[
        const Text('Word count per round:'),
        IntSlider(
          min: kGameRoundsMin,
          max: kGameRoundsMax,
          ini_val: kGameRoundsMin,
          onChanged: (v) => {}),
        const Text('Word frequency:'),
        IntSlider(
          min: kFreqMin,
          max: kFreqMax,
          ini_val: kFreqMin,
          onChanged: (v) => {}),
        const Divider(),
        LabelledSwitch(
          ini_val: false,
          label: "Ignore words with trivial gender:",
          onChanged: (v) => {}),
        LabelledSwitch(
          ini_val: false,
          label: "Ignore feminine professions:",
          onChanged: (v) => {}),
        LabelledSwitch(
          ini_val: false,
          label: "Ignore english words (approx):",
          onChanged: (v) => {}),
        LabelledSwitch(
          ini_val: false,
          label: "Ignore funky words:",
          onChanged: (v) => {}),
        const Divider(),
        FilledButton(
          child: const Text("Reset config and game history"),
          onPressed: () => {},
        ),
      ],
    );
  }
}

