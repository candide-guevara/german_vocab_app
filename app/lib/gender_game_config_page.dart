import 'package:flutter/material.dart';
import 'backend/game_config.dart';
import 'backend/game_history_loader.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';
import 'widgets/future_builder.dart';
import 'widgets/int_slider.dart';
import 'widgets/labelled_switch.dart';

class GenderGameConfigPage extends StatelessWidget {
  static const String kPageTitle = "GenderGameConfig";
  static final int kFailCntMin = 0;
  static final int kFailCntMax = 10;
  final GenderGameConfig conf;

  GenderGameConfigPage({super.key}):
    conf = GenderGameConfig.def();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kPageTitle)),
      body: myFutureBuilder<bool>(
        loadConfFuture(),
        'Loading preferences ...',
        builderAfterLoad,
      ),
    );
  }

  Future<bool> loadConfFuture() async {
    await Future.wait([
      Persistence.isLoaded(),
      GenderGameHistoryLoader.isLoaded(),
    ]);
    conf.setFrom(await GenderGameConfig.load());
    return true;
  }

  Widget builderAfterLoad(final BuildContext context, final bool _) {
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
        ini_val: conf.word_cnt,
        onChanged: (v) async { conf.word_cnt = v; await conf.save(); }),
    );
    final frq_slider = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => IntSlider(
        key: UniqueKey(),
        min: kFreqMin,
        max: kFreqMax,
        ini_val: conf.min_freq,
        onChanged: (v) async { conf.min_freq = v; await conf.save(); }),
    );
    final fal_slider = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => IntSlider(
        key: UniqueKey(),
        min: kFailCntMin,
        max: kFailCntMax,
        ini_val: conf.inc_fail,
        onChanged: (v) async { conf.inc_fail = v; await conf.save(); }),
    );
    final trv_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: conf.has(TagType.TrivialGender),
        label: "Ignore words with trivial gender:",
        onChanged: (v) async {
          conf.set(TagType.TrivialGender, remove:!v);
          await conf.save();
        }),
    );
    final fem_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: conf.has(TagType.FemProfession),
        label: "Ignore feminine professions:",
        onChanged: (v) async {
          conf.set(TagType.FemProfession, remove:!v);
          await conf.save();
        }),
    );
    final eng_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: conf.has(TagType.LikelyEnglish),
        label: "Ignore english words (approx):",
        onChanged: (v) async {
          conf.set(TagType.LikelyEnglish, remove:!v);
          await conf.save();
        }),
    );
    final fky_switch = ListenableBuilder(
      listenable: notify,
      builder: (ctx, child) => LabelledSwitch(
        key: UniqueKey(),
        ini_val: conf.has(TagType.Funky),
        label: "Ignore funky words:",
        onChanged: (v) async {
          conf.set(TagType.Funky, remove:!v);
          await conf.save();
        }),
    );
    final rst_buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FilledButton(
          child: const Text("Reset config"),
          onPressed: () async {
            conf.reset();
            await conf.save();
            notify.value++;
          },),
        FilledButton(
          child: const Text("Reset history"),
          onPressed: () async {
            bool? confirmed = await showDialog(
              context: context,
              builder: buildConfirmationDialog,);
            if (confirmed ?? false) { await GenderGameHistoryLoader.clear(); }
          },),
      ],
    );
    return CenterColumn(
      children: <Widget>[
        const Text('Word count per round:'),
        cnt_slider,
        const Text('Word frequency:'),
        frq_slider,
        const Text('Include failed:'),
        fal_slider,
        trv_switch,
        fem_switch,
        eng_switch,
        fky_switch,
        const Divider(),
        rst_buttons,
      ],
    );
  }

  Widget buildConfirmationDialog(BuildContext context) {
    return AlertDialog(
      content: Text('Delete all game history?'),
      actions: [
        TextButton(
          onPressed: () { Navigator.of(context).pop(false); },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () { Navigator.of(context).pop(true); },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}

