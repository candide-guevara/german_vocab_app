import 'package:flutter/material.dart';

class LabelledSwitch extends StatefulWidget {
  final bool ini_val;
  final String label;
  final void Function(bool) onChanged;
  const LabelledSwitch({super.key,
                        required this.ini_val,
                        required this.label,
                        required this.onChanged});

  @override
  State<LabelledSwitch> createState() => _LabelledSwitchState(ini_val);
}

class _LabelledSwitchState extends State<LabelledSwitch> {
  bool _v;
  _LabelledSwitchState(bool v): _v = v;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(widget.label),
        Switch(value: _v, onChanged: onChanged),
      ],
    );
  }
  void onChanged(bool v) {
    setState(() { _v = v; });
    widget.onChanged(v);
  }
}

