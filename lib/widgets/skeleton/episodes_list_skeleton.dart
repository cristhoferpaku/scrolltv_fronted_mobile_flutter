import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class EpisodesListSkeleton extends StatelessWidget {
  const EpisodesListSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.r, // Altura fija para el scroll horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll horizontal
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
        itemCount: 6, // Mostrar 6 elementos skeleton
        itemBuilder: (context, index) {
          return Container(
            width: 140.r, // Ancho fijo para cada card
            margin: EdgeInsets.only(right: AppPadding.p12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ShimmerAnimation(
              shimmerGradient,
              double.infinity,
              double.infinity,
              8.r,
            ),
          );
        },
      ),
    );
  }
}
