import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';
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
                      Navigator.pushNamed(context, Routes.liveTvRoute);
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
                // Channel List
                Expanded(
                  flex: 1,
                  child: BlocBuilder<TvPlayerBloc, TvPlayerState>(
                    bloc: tvPlayerBloc,
                    builder: (context, state) {
                      return SizedBox(
                        height: 20,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final channels = List<ChannelModel>.from(state.channels.length > 3 ? state.channels.sublist(0, 3) : state.channels);

                            channels.add(ChannelModel(id: 0, name: 'Ver lista', category: ['Ver lista'], url: '', logo: ImageAssets.iconMenu));
                            final availableWidth = constraints.maxWidth;
                            final spacing = 12.0;
                            final totalSpacing = spacing * (channels.length - 1);
                            final channelWidth = (availableWidth - totalSpacing) / channels.length;

                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: channels.length,
                              separatorBuilder: (context, index) => SizedBox(width: spacing),
                              itemBuilder: (context, index) {
                                // final isSelected = index == selectedChannelIndex;
                                return ContainerFocus(
                                  onTap: () async {
                                    if (channels[index].id != 0) {
                                      tvPlayerBloc.add(TvPlayerEvent.changeChannel(channels[index]));
                                    } else {
                                      await Navigator.pushNamed(context, Routes.liveTvRoute);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 24.r),
                                    constraints: BoxConstraints(
                                      minWidth: 150.r,
                                    ),
                                    width: channelWidth.r,
                                    height: 20.r,
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
                              },
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
