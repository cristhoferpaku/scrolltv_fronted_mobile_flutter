import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/gradient_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final bool isTV = PlatformUtils.isTV;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage:
          isTV ? ImageAssets.backgroundTv : ImageAssets.backgroundMobile,
      linearGradient: GradientManager().background(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeNavbar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppPadding.p8.r,
                children: [
                  Text(
                    "Política y Privacidad",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam suscipit, mauris non gravida bibendum, nulla orci tempor sem, nec pretium ipsum purus vitae est. Integer porta nisi id nisl tincidunt, ac volutpat lorem pretium. Proin posuere, enim vel posuere dignissim, nulla purus dapibus justo, vel euismod lacus lacus nec arcu."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
