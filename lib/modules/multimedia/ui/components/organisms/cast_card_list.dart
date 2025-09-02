import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/cast_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class CastCardList extends StatelessWidget {
  final List<CastModel> casts;
  const CastCardList({
    super.key,
    required this.casts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: AppPadding.p12.r,
      children: [
        Text("Reparto", style: Theme.of(context).textTheme.titleLarge),
        if (casts.isEmpty)
          NoContentBox()
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppPadding.p24.r,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                casts.length,
                (index) => CastCard(cast: casts[index]),
              ),
            ),
          ),
      ],
    );
  }
}
