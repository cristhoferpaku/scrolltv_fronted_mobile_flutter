import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/live_tv_tab.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/movies_tab.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';

class HomeTabBar extends StatefulWidget {
  const HomeTabBar({
    super.key,
  });

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
        titleBar: HomeNavbar()
            .withPadding(horizontal: AppPadding.p16, vertical: AppPadding.p16),
        items: [
          CustomTabBarItem(
              title: AppStringMultimedia.sectionLive,
              icon: SvgPicture.asset(
                ImageAssets.iconLive,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: LiveTab()),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionMovies,
              icon: SvgPicture.asset(
                ImageAssets.iconMovie,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: MoviesTab(scrollController: scrollController)),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionSeries,
              icon: SvgPicture.asset(
                ImageAssets.iconPlay,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: MoviesTab(scrollController: scrollController)),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionKids,
              icon: SvgPicture.asset(
                ImageAssets.iconKid,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: MoviesTab(scrollController: scrollController)),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionAnimes,
              icon: SvgPicture.asset(
                ImageAssets.iconAnime,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: MoviesTab(scrollController: scrollController)),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionDrama,
              icon: SvgPicture.asset(
                ImageAssets.iconDrama,
                fit: BoxFit.contain,
                width: ResponsiveUtils.getIconSize(context),
              ),
              child: MoviesTab(scrollController: scrollController)),
        ]);
  }
}
