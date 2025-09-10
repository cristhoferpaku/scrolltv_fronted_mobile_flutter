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

class DramasTab extends StatefulWidget {
  const DramasTab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<DramasTab> createState() => _DramasTabState();
}

class _DramasTabState extends State<DramasTab> {
  final ScrollController scrollController = ScrollController();

  final HomeBloc homeBloc = instance<HomeBloc>();

  @override
  void initState() {
    homeBloc.add(HomeEvent.loadSectionDramas());
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
              return current.status == HomeStateStatus.loadedDramas || current.status == HomeStateStatus.loadingDramas;
            }
            return false;
          },
          bloc: homeBloc,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is HomeStateLoaded) {
              if (state.status == HomeStateStatus.loadingDramas) {
                return HomeSkeleton();
              }
              return Column(
                children: [
                  FocusTraversalGroup(
                    policy: CustomGridTraversalPolicyStrictVertical(),
                    child: Column(
                      spacing: AppPadding.p36,
                      children: [
                        HomeHero(video: state.dramas?.banner ?? VideoModel()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CollectionList(collection: state.dramas?.collectionsContent ?? []),
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
