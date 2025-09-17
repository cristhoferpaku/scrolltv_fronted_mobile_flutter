import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_view.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveTab extends StatefulWidget {
  const LiveTab({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> with RouteAware {
  final HomeBloc homeBloc = instance<HomeBloc>();
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();
  // int selectedChannelIndex = 0;
  final isTv = PlatformUtils.isTV;

  late final VlcPlayerController controller;
  bool _isVisible = true;

  @override
  void initState() {
    WakelockPlus.enable();
    homeBloc.add(HomeEvent.loadSectionLive());
    super.initState();
    controller = VlcPlayerController.network(
      tvPlayerBloc.state.selectedChannelIndex?.url ?? "",
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  // @override
  // void didUpdateWidget(covariant LiveTab oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.scrollController != widget.scrollController) {
  //     controller.stop();
  //     controller.setMediaFromNetwork(tvPlayerBloc.state.channels[0].url, autoPlay: true);
  //   }
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    controller.stop(); // otra pantalla encima → detener video
    _isVisible = false;
  }

  @override
  void didPopNext() {
    controller.play(); // volvemos → reanudar video
    _isVisible = true;
  }

  // Detecta cuando la app entra en background/foreground
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     controller.pause();
  //   } else if (state == AppLifecycleState.resumed) {
  //     controller.play();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlurBackground(
          top: 0,
          left: 0,
          width: 300,
          height: 300,
          offset: Offset(-100, 0),
        ),
        BlurBackground(
          right: 0,
          bottom: 0,
          width: 300,
          height: 300,
          offset: Offset(100, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FocusTraversalGroup(
            policy: CustomGridTraversalPolicyStrictVertical(),
            child: Column(
              children: [
                // Video Player Area
                isTv ? const SizedBox(height: 140) : const SizedBox(height: 0),
                Expanded(
                  flex: 3,
                  child: ContainerFocus(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.liveTvRoute, arguments: LiveTvDetailArguments(showChannelList: false));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: BlocConsumer<TvPlayerBloc, TvPlayerState>(
                          bloc: tvPlayerBloc,
                          buildWhen: (previous, current) {
                            return _isVisible;
                          },
                          listener: (context, state) {
                            if (state.status == TVPlayerStatus.changeChannelSuccess) {
                              controller.setMediaFromNetwork(state.selectedChannelIndex?.url ?? '', autoPlay: _isVisible);
                            }
                          },
                          builder: (context, state) {
                            return VideoPlayerView(
                              controller: controller,
                              aspectRatio: 16 / 9,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  flex: 1,
                  child: BlocBuilder<TvPlayerBloc, TvPlayerState>(
                    bloc: tvPlayerBloc,
                    builder: (context, state) {
                      return SizedBox(
                        height: 20,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              children: [
                                if (state.status == TVPlayerStatus.loadingChannels)
                                  Expanded(
                                    child: Row(
                                      spacing: AppPadding.p16,
                                      children: List.generate(
                                        4,
                                        (index) => Expanded(child: ShimmerAnimation(shimmerGradient, 0, double.infinity, 8)),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Row(
                                      spacing: AppPadding.p16,
                                      children: List.generate(
                                        state.homeCategories.length,
                                        (index) => Expanded(child: channel_home_card(channels: state.homeCategories, tvPlayerBloc: tvPlayerBloc, channelWidth: 120, index: index)),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class channel_home_card extends StatelessWidget {
  const channel_home_card({
    super.key,
    required this.channels,
    required this.tvPlayerBloc,
    required this.channelWidth,
    required this.index,
  });

  final List<ChannelModel> channels;
  final TvPlayerBloc tvPlayerBloc;
  final double channelWidth;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: () async {
        if (channels[index].id != 0) {
          tvPlayerBloc.add(TvPlayerEvent.changeChannel(channels[index]));
        } else {
          await Navigator.pushNamed(context, Routes.liveTvRoute, arguments: LiveTvDetailArguments(showChannelList: true));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        constraints: BoxConstraints(
          minWidth: 150.r,
        ),
        width: channelWidth.r,
        height: double.infinity,
        decoration: BoxDecoration(
          color: ColorManager.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: (channels[index].id != 0)
            ? Row(
                spacing: 12.r,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Channel logo/icon placeholder
                  // Channel name

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ImageWithPlaceholder(
                      width: 60.r,
                      height: 60.r,
                      imageUrl: channels[index].logo,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      channels[index].name,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  // Channel subtitle
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageWithPlaceholder(
                    width: 40.r,
                    height: 40.r,
                    imageUrl: channels[index].logo,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    channels[index].name,
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
      ),
    );
  }
}
