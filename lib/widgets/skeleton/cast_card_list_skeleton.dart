import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/cast_card_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/text_skeleton.dart';

class CastCardListSkeleton extends StatelessWidget {
  const CastCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: AppPadding.p12.r,
      children: [
        TextSkeleton(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppPadding.p24.r,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              5,
              (index) => CastCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}
