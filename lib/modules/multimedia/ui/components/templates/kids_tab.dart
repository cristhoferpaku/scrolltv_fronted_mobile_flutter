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

class KidsTab extends StatefulWidget {
  const KidsTab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<KidsTab> createState() => _KidsTabState();
}

class _KidsTabState extends State<KidsTab> {
  final ScrollController scrollController = ScrollController();

  final HomeBloc homeBloc = instance<HomeBloc>();

  @override
  void initState() {
    homeBloc.add(HomeEvent.loadSectionKids());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollToTopOnUp(
      scrollController: widget.scrollController,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: BlocConsumer<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (current is HomeStateLoaded) {
              return current.status == HomeStateStatus.loadedKids || current.status == HomeStateStatus.loadingKids;
            }
            return false;
          },
          bloc: homeBloc,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is HomeStateLoaded) {
              if (state.status == HomeStateStatus.loadingKids) {
                return HomeSkeleton();
              }
              return Column(
                children: [
                  FocusTraversalGroup(
                    policy: CustomGridTraversalPolicy(),
                    child: Column(
                      spacing: AppPadding.p36,
                      children: [
                        HomeHero(video: state.kids?.banner ?? VideoModel()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CollectionList(collection: state.kids?.collectionsContent ?? []),
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
