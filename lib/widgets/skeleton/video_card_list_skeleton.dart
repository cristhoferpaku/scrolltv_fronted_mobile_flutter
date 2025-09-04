import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/video_card_skeleton.dart';

class VideoCardListSkeleton extends StatelessWidget {
  const VideoCardListSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: EdgeInsets.all(AppPadding.p16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (constraints.maxWidth / 140).floor(), // columnas
            crossAxisSpacing: AppPadding.p16,
            mainAxisSpacing: AppPadding.p16,
            childAspectRatio: 140.r / 200.r,
          ),
          itemCount: (constraints.maxWidth / 140).floor() * 2,
          itemBuilder: (context, index) {
            return VideoCardSkeleton();
          },
        );
      },
    );
  }
}
