import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/scroll_to_top_on_up.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/top_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class MoviesTab extends StatefulWidget {
  const MoviesTab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends State<MoviesTab> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ScrollToTopOnUp(
      scrollController: widget.scrollController,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          children: [
            FocusTraversalGroup(
              policy: CustomGridTraversalPolicy(),
              child: Column(
                spacing: AppPadding.p36,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1,
                    child: HomeHero(),
                  ),
                  Column(
                    children: [
                      TopCardList(title: AppStringMultimedia.sectionMovies),
                      SectionCardList(
                          title: AppStringMultimedia.sectionSeries,
                          hasBlurLeft: true),
                      SectionCardList(
                          title: AppStringMultimedia.sectionDrama,
                          hasBlurRight: true),
                      SectionCardList(title: AppStringMultimedia.sectionKids),
                      SectionCardList(
                          title: AppStringMultimedia.sectionAnimes,
                          hasBlurLeft: true),
                    ],
                  ).withPadding(all: AppPadding.p16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
