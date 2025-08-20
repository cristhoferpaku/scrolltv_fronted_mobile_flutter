import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/scroll_to_top_on_up.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/bloc/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class AnimesTab extends StatefulWidget {
  const AnimesTab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<AnimesTab> createState() => _AnimesTabState();
}

class _AnimesTabState extends State<AnimesTab> {
  final ScrollController scrollController = ScrollController();

  final HomeBloc homeBloc = instance<HomeBloc>();

  @override
  Widget build(BuildContext context) {
    return ScrollToTopOnUp(
      scrollController: widget.scrollController,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: BlocConsumer<HomeBloc, HomeState>(
          bloc: homeBloc,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is HomeStateLoadedSections) {
              return Column(
                children: [
                  FocusTraversalGroup(
                    policy: CustomGridTraversalPolicy(),
                    child: Column(
                      spacing: AppPadding.p36,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 1,
                          child: HomeHero(
                              video: state.animes?.banner ?? VideoModel()),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SectionCardList(
                                title: "Recién llegadas",
                                hasBlurLeft: true,
                                hasBlurRight: true,
                                videos: state.animes?.recentContent ?? []),
                            Column(
                              children: [
                                if (state.animes?.collectionsContent
                                        ?.isNotEmpty ??
                                    false)
                                  ...state.animes!.collectionsContent!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final e = entry.value;
                                    return SectionCardList(
                                      title: e.collectionName ?? "",
                                      hasBlurLeft: index % 2 == 0 && index != 0
                                          ? true
                                          : false,
                                      hasBlurRight:
                                          index % 2 == 1 ? true : false,
                                      videos: e.content ?? [],
                                    );
                                  }),
                              ],
                            )
                          ],
                        ).withPadding(all: AppPadding.p16),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
