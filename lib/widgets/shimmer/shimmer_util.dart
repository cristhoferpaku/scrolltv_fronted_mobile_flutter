import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_loading.dart';

// ignore: non_constant_identifier_names
Widget ShimmerAnimation(LinearGradient shimmerGradient, double shimmerWidth, double shimmerHeight, double shimmerBorderCorner, {double? horizontalMargin = 0, double? verticalMargin = 0}) {
  return ContainerFocus(
    child: Shimmer(
      linearGradient: shimmerGradient,
      child: ShimmerLoading(
        isLoading: true,
        child: Container(
          margin: EdgeInsetsDirectional.symmetric(horizontal: horizontalMargin ?? 0, vertical: verticalMargin ?? 0),
          width: shimmerWidth,
          height: shimmerHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(shimmerBorderCorner),
          ),
        ),
      ),
    ),
  );
}
