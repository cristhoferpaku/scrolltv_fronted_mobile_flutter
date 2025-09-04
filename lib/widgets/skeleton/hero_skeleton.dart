import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class HeroSkeleton extends StatelessWidget {
  final double height;
  const HeroSkeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      shimmerGradient,
      double.infinity,
      height,
      16,
    );
  }
}
