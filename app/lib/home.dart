import 'package:flutter/material.dart';
import 'widgets/center_column.dart';
import 'gender_game.dart';
import 'utils.dart';

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
            child: const Text("TODO"),
            onPressed: () => {},
          ),
        ],
      ),
    );
  }
}

