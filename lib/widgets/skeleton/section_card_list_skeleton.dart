import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/section_card_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/text_skeleton.dart';

class SectionCardListSkeleton extends StatelessWidget {
  const SectionCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppPadding.p16,
      children: [
        TextSkeleton(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppPadding.p16,
            children: List.generate(
              5,
              (index) => SectionCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}
