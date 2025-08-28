import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/cast_card_list_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/hero_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/section_card_list_skeleton.dart';

class VideoDetailsSkeleton extends StatelessWidget {
  const VideoDetailsSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.sh,
      child: SingleChildScrollView(
        child: FocusTraversalGroup(
          policy: CustomGridTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: AppPadding.p16.r,
            children: [
              HeroSkeleton(height: .7.sh),
              CastCardListSkeleton(),
              SectionCardListSkeleton(),
              SectionCardListSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}
