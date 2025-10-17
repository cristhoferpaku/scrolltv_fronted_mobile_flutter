import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/scroll_to_top_on_up.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/cast_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/collection_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/season_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/video_details/video_details_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/app_dialog_customize.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/section_card_list_skeleton.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/video_details_skeleton.dart';

class VideoDetailsPage extends StatefulWidget {
  const VideoDetailsPage({super.key});

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  final VideoDetailsBloc videoDetailsBloc = instance<VideoDetailsBloc>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as VideoDetailsPageArguments;
      videoDetailsBloc.add(VideoDetailsEvent.started(arguments.videoId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: 0,
      body: ScrollToTopOnUp(
        scrollController: _scrollController,
        height: 1,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: FocusTraversalGroup(
            policy: CustomGridTraversalPolicy(),
            child: BlocConsumer<VideoDetailsBloc, VideoDetailsState>(
              bloc: videoDetailsBloc,
              listener: (context, state) {},
              builder: (context, state) {
                if (state is VideoDetailsStateLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (state.status == VideoDetailsStateStatus.error)
                        ContainerError(
                          message: 'El video no esta disponible en estos momentos',
                        )
                      else if (state.status == VideoDetailsStateStatus.loadingVideo)
                        VideoDetailsSkeleton()
                      else if (state.videoContent?.video != null)
                        HomeHero(
                          height: .9.sh,
                          detailsDisabled: true,
                          goBack: true,
                          video: state.videoContent!.video!,
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: AppPadding.p32.r,
                        children: [
                          if (state.videoContent?.seasons != null) SeasonTabBar(seasons: state.videoContent!.seasons!),
                          if (state.videoContent?.casts != null && state.videoContent?.video?.firstSeasonId == null) CastCardList(casts: state.videoContent!.casts!),
                          if (state.status == VideoDetailsStateStatus.loadingSection) SectionCardListSkeleton() else if (state.collections != null) CollectionList(collection: state.collections!),
                        ],
                      ).withPadding(top: AppPadding.p32.r, horizontal: AppPadding.p16.r),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ContainerError extends StatelessWidget {
  final String message;
  const ContainerError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.sh,
      child: Center(
        child: AppDialogCustomize(
          canPop: true,
          message: message,
          type: AppDialogCustomizeType.error,
          onPressed: () {
            Navigator.pop(context);
          },
          labelActionButton: "Regresar",
          showCancelButton: false,
        ),
      ),
    );
  }
}
