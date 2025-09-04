import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/avatar/circle_avatar_asset.dart';

class CastCard extends StatelessWidget {
  final CastModel cast;
  const CastCard({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: () {},
      borderRadius: 999,
      child: Row(
        spacing: AppPadding.p10.r,
        children: [
          CircleAvatarAsset(
            radiusAvatar: 44.r / 2,
            pathAsset: "",
            networkAsset: cast.image ?? "",
          ),
          Text(cast.name ?? ""),
        ],
      ),
    );
  }
}
