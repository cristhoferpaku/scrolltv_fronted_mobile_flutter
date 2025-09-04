import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class CastCardSkeleton extends StatelessWidget {
  const CastCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      shimmerGradient,
      44.r,
      44.r,
      16,
    );
  }
}
