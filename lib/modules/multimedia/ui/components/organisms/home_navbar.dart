import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class HomeNavbar extends StatelessWidget {
  const HomeNavbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppPadding.p16,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          ImageAssets.logoScrollTv,
          width: 100,
          height: 50,
        ),
        SvgPicture.asset(
          ImageAssets.iconSearch,
          width: 24,
          height: 24,
        ),
      ],
    );
  }
}
