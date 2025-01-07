import 'package:flutter/material.dart';
import 'center_column.dart';
import 'utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppTitle)),
      body: CenterColumn(
        children: <Widget>[
          ElevatedButton(
            child: const Text("coucou"),
            onPressed: () => {},
          ),
          ElevatedButton(
            child: const Text("salut"),
            onPressed: () => {},
          ),
        ],
      ),
    );
  }
}

