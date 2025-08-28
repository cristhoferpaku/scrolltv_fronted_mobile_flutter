import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class CastCard extends StatelessWidget {
  final CastModel cast;
  const CastCard({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppPadding.p10.r,
      children: [
        CircleAvatar(
          radius: 44.r / 2,
          child: Text(cast.name ?? ""),
        ),
        Text(cast.name ?? ""),
      ],
    );
  }
}
