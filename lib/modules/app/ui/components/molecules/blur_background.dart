import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class BlurBackground extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;
  final double? height;
  final double? sigmaX;
  final double? sigmaY;
  final Offset? offset;
  final Color? color;
  const BlurBackground({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width = 0,
    this.height = 0,
    this.sigmaX = 200,
    this.sigmaY = 200,
    this.offset,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: offset ?? Offset(0, 0),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigmaX ?? width!, sigmaY: sigmaY ?? height!),
          child: Container(
            width: width ?? MediaQuery.of(context).size.width * 0.9,
            height: height ?? MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: color ?? ColorManager.primary300.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
