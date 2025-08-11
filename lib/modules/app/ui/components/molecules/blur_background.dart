import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class BlurBackground extends StatelessWidget {
  final double top;
  final double left;
  const BlurBackground({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.translate(
        offset: Offset(0, 0),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: ColorManager.primary300.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
