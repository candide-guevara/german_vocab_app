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

  Widget builderAfterLoad(final BuildContext context, final GenderGameConfig g) {
    // BE CAREFUL IT IS A TRAP!
    // You need to use unique keys to force the state to be recreated when
    // the ListenableBuilder recreates teh widget.
    // Otherwise the new wiget gets the old state (not sure why...)
    final notify = ValueNotifier<int>(0);
    final cnt_slider = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => IntSlider(
        key: UniqueKey(),
        min: kGameRoundsMin,
        max: kGameRoundsMax,
        ini_val: g.word_cnt,
        onChanged: (v) async { g.word_cnt = v; await g.save(); }),
    );
    final frq_slider = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => IntSlider(
        key: UniqueKey(),
        min: kFreqMin,
        max: kFreqMax,
        ini_val: g.min_freq,
        onChanged: (v) async { g.min_freq = v; await g.save(); }),
    );
    final trv_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: g.has(TagType.TrivialGender),
        label: "Ignore words with trivial gender:",
        onChanged: (v) async {
          g.set(TagType.TrivialGender, remove:!v);
          await g.save();
        }),
    );
    final fem_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: g.has(TagType.FemProfession),
        label: "Ignore feminine professions:",
        onChanged: (v) async {
          g.set(TagType.FemProfession, remove:!v);
          await g.save();
        }),
    );
    final eng_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: g.has(TagType.LikelyEnglish),
        label: "Ignore english words (approx):",
        onChanged: (v) async {
          g.set(TagType.LikelyEnglish, remove:!v);
          await g.save();
        }),
    );
    final fky_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: g.has(TagType.Funky),
        label: "Ignore funky words:",
        onChanged: (v) async {
          g.set(TagType.Funky, remove:!v);
          await g.save();
        }),
    );
    final rst_button = FilledButton(
      child: const Text("Reset config and game history"),
      onPressed: () async { 
        g.reset();
        await g.save();
        notify.value++;
      },
    );
    return CenterColumn(
      children: <Widget>[
        const Text('Word count per round:'),
        cnt_slider,
        const Text('Word frequency:'),
        frq_slider,
        const Divider(),
        trv_switch,
        fem_switch,
        eng_switch,
        fky_switch,
        const Divider(),
        rst_button,
      ],
    );
  }
}

