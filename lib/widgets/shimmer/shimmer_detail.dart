import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';

const shimmerGradient = LinearGradient(
  colors: [
    ColorManager.shimmerStart,
    ColorManager.shimmerEffect,
    ColorManager.shimmerStart,
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);