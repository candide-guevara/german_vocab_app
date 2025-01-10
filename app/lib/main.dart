import 'package:flutter/material.dart';
import 'gender_game_page.dart';
import 'gender_game_config_page.dart';
import 'backend/dictionary_loader.dart';
import 'backend/utils.dart';
import 'widgets/center_column.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DictionaryLoader.init();

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
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: CenterColumn(
        children: <Widget>[
          FilledButton(
            child: const Text(GenderGame.kPageTitle),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenderGame())),
          ),
          FilledButton(
            child: const Text(GenderGameConfigPage.kPageTitle),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenderGameConfigPage())),
          ),
        ],
      ),
    );
  }
}

