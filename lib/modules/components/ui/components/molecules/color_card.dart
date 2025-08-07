import 'package:flutter/material.dart';

class ColorCard extends StatelessWidget {
  final Color color;
  final String name;
  const ColorCard({super.key, required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          color: color,
        ),
        Text(name),
      ],
    );
  }
}
