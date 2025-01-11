import 'package:flutter/material.dart';
import 'center_column.dart';

FutureBuilder myFutureBuilder<K>(Future<K> future,
                                 String loadMsg,
                                 Widget Function(BuildContext, K) afterLoad) {
  return FutureBuilder<K>(
    future: future,
    builder: _builderAfterLoad<K>(loadMsg, afterLoad),
  );
}

AsyncWidgetBuilder<K> _builderAfterLoad<K>(String loadMsg,
                                           Widget Function(BuildContext, K) afterLoad) {
  return (BuildContext context, AsyncSnapshot<K> snapshot) {
    if (snapshot.hasData) {
      return afterLoad(context, snapshot.data!);
    }
    if (snapshot.hasError) {
      return CenterColumn(
        children: <Widget>[
          const Icon( Icons.error_outline, color: Colors.red, size: 60,),
          Padding( padding: const EdgeInsets.only(top: 16), child: Text('Error: ${snapshot.error}'),),
        ],
      );
    }
    return CenterColumn(
      children: <Widget>[
        Text(loadMsg, style: Theme.of(context).textTheme.titleLarge,),
        CircularProgressIndicator(semanticsLabel: loadMsg),
      ],
    );
  };
}

