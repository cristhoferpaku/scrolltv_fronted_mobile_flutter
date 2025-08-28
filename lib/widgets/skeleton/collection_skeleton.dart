import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/text_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/video_card_list_skeleton.dart';

class CollectionSkeleton extends StatelessWidget {
  const CollectionSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 1.sh,
        child: Column(
          spacing: AppPadding.p16.r,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSkeleton(),
            Expanded(child: VideoCardListSkeleton()),
          ],
        ).withPadding(top: AppPadding.p32));
  }
}
