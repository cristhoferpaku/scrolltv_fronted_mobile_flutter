import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class VideoCardSkeleton extends StatelessWidget {
  const VideoCardSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerAnimation(
      shimmerGradient,
      140.r,
      200.r,
      8.r,
    );
  }
}
