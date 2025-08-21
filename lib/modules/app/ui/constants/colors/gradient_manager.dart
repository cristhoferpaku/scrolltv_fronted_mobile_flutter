import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class GradientManager {
  LinearGradient background() {
    if (PlatformUtils.isTV) {
      return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.80),
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: [0.0, 0.5, 1.0],
          );
    } else {
      return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.80),
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: [0.0, 0.5, 1.0],
          );
    }
  }
}
