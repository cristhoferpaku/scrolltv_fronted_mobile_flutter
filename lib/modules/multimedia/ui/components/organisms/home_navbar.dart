import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/top_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/mobile/mobile.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';

class HomeNavbar extends StatelessWidget {
  const HomeNavbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
        titleBar: Image.asset(
          ImageAssets.logoScrollTv,
          width: 100,
          height: 50,
        ).withPadding(horizontal: AppPadding.p16, vertical: AppPadding.p16),
        items: [
          CustomTabBarItem(
              title: AppStringMultimedia.sectionMovies,
              icon: Icons.movie,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: AppPadding.p280),
                    Column(
                      spacing: AppPadding.p36,
                      children: [
                        TopCardList(title: AppStringMultimedia.sectionMovies),
                        SectionCardList(
                            title: AppStringMultimedia.sectionSeries),
                        SectionCardList(
                            title: AppStringMultimedia.sectionDocumentaries),
                        SectionCardList(title: AppStringMultimedia.sectionKids),
                        SectionCardList(
                            title: AppStringMultimedia.sectionAnimes),
                      ],
                    ),
                  ],
                ).withPadding(all: AppPadding.p16),
              )),
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
