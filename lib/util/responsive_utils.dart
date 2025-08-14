import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getSize(
    BuildContext context, {
    double minSize = 100.0,
    double maxSize = 400.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final minScreen = 375.0;
    final maxScreen = 1920.0;

    final m = (maxSize - minSize) / (maxScreen - minScreen);

    double width = minSize + (screenWidth - minScreen) * m;

    // Evitar que se pase de los límites
    return width.clamp(minSize, maxSize);
  }
}
