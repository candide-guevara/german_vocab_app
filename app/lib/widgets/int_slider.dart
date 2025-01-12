import 'package:flutter/material.dart';

class IntSlider extends StatefulWidget {
  final int min;
  final int max;
  final int ini_val;
  final int divisions;
  final Future<void> Function(int) onChanged;

  const IntSlider({super.key,
      required this.min,
      required this.max,
      required this.ini_val,
      required this.onChanged}):
    divisions = (max - min) > 9 ? 9 : (max - min - 1);

  @override
  State<IntSlider> createState() => _IntSliderState(ini_val);
}

class _IntSliderState extends State<IntSlider> {
  double _v;
  _IntSliderState(int v): _v = v.toDouble();

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _v,
      min: widget.min.toDouble(),
      max: widget.max.toDouble(),
      divisions: widget.divisions,
      label: _v.round().toString(),
      onChanged: this.onChanged,
    );
  }
  void onChanged(double v) async {
    setState(() { _v = v; });
    await widget.onChanged(v.round());
  }
}

