import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class HomeNavbar extends StatefulWidget {
  const HomeNavbar({
    super.key,
  });

  @override
  State<HomeNavbar> createState() => _HomeNavbarState();
}

class _HomeNavbarState extends State<HomeNavbar> {
  final bool isTV = PlatformUtils.isTV;
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: CustomGridTraversalPolicy(),
      child: Row(
        spacing: AppPadding.p16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            ImageAssets.logoScrollTv,
            width: 100,
            height: 50,
          ),
          Row(
            spacing: AppPadding.p16,
            children: [
              ContainerFocus(
                onTap: () {},
                borderRadius: 999,
                child: SvgPicture.asset(
                  ImageAssets.iconSearch,
                  width: ResponsiveUtils.getIconSize(context, minSize: 32, maxSize: 58),
                ),
              ),
              if (isTV)
                ContainerFocus(
                  borderRadius: 999,
                  child: CircleAvatar(
                    radius: ResponsiveUtils.getIconSize(context, minSize: 32, maxSize: 58) / 2,
                    child: Text(
                      "D",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.profileRoute);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
