import 'package:flutter/material.dart';

class ValuesManager {
  static List<Color> heroLinearGradientColors = [
    Colors.black.withValues(alpha: 0.9),
    Colors.black.withValues(alpha: 0.9),
    Colors.black.withValues(alpha: 0.16),
  ];
  static List<double> heroLinearGradientStops = [0.0, 0.5, 1.0];
  static Alignment heroLinearGradientBegin = Alignment.bottomLeft;
  static Alignment heroLinearGradientEnd = Alignment.topRight;
}
