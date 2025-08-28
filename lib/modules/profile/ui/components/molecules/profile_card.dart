import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/info_row.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/blur_container.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class ProfileCard extends StatelessWidget {
  final UserModel? user;
  final Function() onTap;
  const ProfileCard({
    super.key,
    this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: () {},
      child: BlurContainer(
        child: Row(
          spacing: AppPadding.p16,
          children: [
            CircleAvatar(
              radius: 75.r / 2,
              child: Text("D", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 38.r)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppPadding.p4.r,
                children: [
                  InfoRow(label: "Cuenta: ", value: user?.username ?? ""),
                  InfoRow(label: "Fecha de expiración: ", value: user?.expirationDate ?? ""),
                  InfoRow(label: "Paquete: ", value: user?.packageUserName ?? ""),
                ],
              ),
            ),
          ],
        ).withPadding(all: 12.w),
      ),
    );
  }
}
