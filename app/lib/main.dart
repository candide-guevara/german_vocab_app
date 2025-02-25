import 'package:flutter/material.dart';
import 'gender_game_page.dart';
import 'gender_game_config_page.dart';
import 'gender_game_history_page.dart';
import 'vocab_game_page.dart';
import 'vocab_game_config_page.dart';
import 'vocab_game_history_page.dart';
import 'backend/dictionary_loader.dart';
import 'backend/game_history_loader.dart';
import 'backend/persistence_store.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DictionaryLoader.init();
  Persistence.init();
  GenderGameHistoryLoader.init();
  VocabGameHistoryLoader.init();

  runApp(MaterialApp(
    builder: (context, child) {
      double scaleFactor = MediaQuery.of(context).size.width / kReferenceWidth;
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scaleFactor.clamp(1.0, 1.5)),
        ),
        child: child!,
      );
    },
    home: HomePage(),
    theme: ThemeData.dark(),
    darkTheme: ThemeData.dark(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final defStyle = Theme.of(context).filledButtonTheme.style ?? ButtonStyle();
    final txtStyle = TextStyle(color: Colors.grey.shade300);
    final genderStyle = defStyle.copyWith(backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.deepPurple.shade600;
        }
        return Colors.deepPurple.shade300;
      },
    ));
    final vocabStyle = defStyle.copyWith(backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.indigo.shade600;
        }
        return Colors.indigo.shade300;
      },
    ));

    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: CenterColumn(
        children: <Widget>[
          FilledButton(
            child: Text(GenderGamePage.kPageTitle, style: txtStyle),
            style: genderStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => GenderGamePage())),
          ),
          FilledButton(
            child: Text(GenderGameHistoryPage.kPageTitle, style: txtStyle),
            style: genderStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenderGameHistoryPage())),
          ),
          FilledButton(
            child: Text(GenderGameConfigPage.kPageTitle, style: txtStyle),
            style: genderStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenderGameConfigPage())),
          ),
          const Divider(),
          FilledButton(
            child: Text(VocabGamePage.kPageTitle, style: txtStyle),
            style: vocabStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VocabGamePage())),
          ),
          FilledButton(
            child: Text(VocabGameHistoryPage.kPageTitle, style: txtStyle),
            style: vocabStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VocabGameHistoryPage())),
          ),
          FilledButton(
            child: Text(VocabGameConfigPage.kPageTitle, style: txtStyle),
            style: vocabStyle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VocabGameConfigPage())),
          ),
        ],
      ),
    );
  }
}

