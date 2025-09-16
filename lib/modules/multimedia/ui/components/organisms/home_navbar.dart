import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/components/molecules/date_time_display.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
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
  final HomeBloc homeBloc = instance<HomeBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {},
      bloc: homeBloc,
      builder: (context, state) {
        if (state is HomeStateLoaded) {
          return FocusTraversalGroup(
              policy: CustomGridTraversalPolicy(),
              child: Row(
                spacing: AppPadding.p16,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    PlatformUtils.getLogo(),
                    width: 100,
                    height: 50,
                  ),
                  Row(
                    spacing: AppPadding.p16,
                    children: [
                      ContainerFocus(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.searchRoute);
                        },
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
                              state.firstLetterUsername ?? "",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.profileRoute);
                          },
                        ),
                      if (isTV)
                        Row(
                          spacing: AppPadding.p16,
                          children: [
                            SizedBox(
                              height: 32,
                              width: 1,
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                            DateTimeDisplay(),
                          ],
                        ),
                    ],
                  ),
                ],
              ));
        } else {
          return Container();
        }
      },
    );
  }
}
