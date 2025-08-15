import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/live_tv_tab.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/movies_tab.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';

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
              icon: Icons.live_tv,
              child: LiveTab()),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionMovies,
              icon: Icons.movie,
              child: MoviesTab(scrollController: scrollController)),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionSeries,
              icon: Icons.card_giftcard,
              child: HomeHero()),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionDocumentaries,
              icon: Icons.card_giftcard,
              child: HomeHero()),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionKids,
              icon: Icons.card_giftcard,
              child: HomeHero()),
          CustomTabBarItem(
              title: AppStringMultimedia.sectionAnimes,
              icon: Icons.card_giftcard,
              child: HomeHero()),
        ]);
  }
}
