import 'package:flutter/material.dart';

class LinearGradientBox extends StatelessWidget {
  const LinearGradientBox({
    super.key,
    required this.colors,
    required this.stops,
    required this.begin,
    required this.end,
  });

  final List<Color> colors;
  final List<double> stops;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}
