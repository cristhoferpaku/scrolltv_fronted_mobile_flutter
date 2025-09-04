import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/scroll_to_top_on_up.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/collection_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/home_skeleton.dart';

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
  void initState() {
    homeBloc.add(HomeEvent.loadSectionAnimes());
    super.initState();
  }

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
            if (state is HomeStateLoaded) {
              if (state.status == HomeStateStatus.loadingAnimes) {
                return HomeSkeleton();
              }
              return Column(
                children: [
                  FocusTraversalGroup(
                    policy: CustomGridTraversalPolicyStrictVertical(),
                    child: Column(
                      spacing: AppPadding.p36,
                      children: [
                        HomeHero(video: state.animes?.banner ?? VideoModel()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                CollectionList(collection: state.animes?.collectionsContent ?? []),
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
