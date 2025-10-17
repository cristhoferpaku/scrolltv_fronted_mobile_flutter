import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/blur_container.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class LogoutCard extends StatelessWidget {
  final Function() onTap;
  const LogoutCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: onTap,
      child: BlurContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageAssets.iconLogout,
              height: 32.r,
            ),
            Text("Cerrar sesión", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.r)).withPadding(top: AppPadding.p8.r),
          ],
        ).withPadding(all: 12.w),
      ),
    );
  }
}
