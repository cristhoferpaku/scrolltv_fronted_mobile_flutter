import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/molecules/channel_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_category_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/constants/focus_enum.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({
    super.key,
    required this.channels,
    required this.focusNodes,
  });

  final List<ChannelModel> channels;
  final List<FocusNode> focusNodes;

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();

  final ScrollController scrollController = ScrollController();

  final bool isTv = PlatformUtils.isTV;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TvPlayerBloc, TvPlayerState>(
      bloc: tvPlayerBloc,
      listener: (context, state) {
        if (state.status == TVPlayerStatus.showPanelChannelByHomeSuccess) {
          tvPlayerBloc.add(TvPlayerEvent.showPanelChannel(true));
          Actions.invoke(
            context,
            DirectionalFocusIntent(TraversalDirection.left),
          );
          return;
        } else if (state.status == TVPlayerStatus.changeCategorySuccess) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(0);
          }
        }
      },
      builder: (context, state) {
        return Container(
          color: !isTv ? ColorManager.neutro900 : Colors.transparent,
          child: Focus(
            canRequestFocus: false,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                tvPlayerBloc.add(TvPlayerEvent.changeFocus(FocusEnum.channelList));
              }
            },
            onKeyEvent: (FocusNode node, event) {
              if (event is KeyDownEvent) {
                if (widget.focusNodes.first.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  return KeyEventResult.handled;
                }
                if (widget.focusNodes.last.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  return KeyEventResult.handled;
                }
                if (state.focusEnum == FocusEnum.channelList && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  tvPlayerBloc.add(TvPlayerEvent.showPanelChannel(false));
                  return KeyEventResult.ignored;
                }
              }
              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                if (!isTv) ChannelCategoryBar(categories: state.categories, selectedCategoryIndex: state.selectedCategoryIndex),
                Expanded(
                  child: Column(
                    children: [
                      if (state.status == TVPlayerStatus.loadingChannels)
                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return const ChannelCardSkeleton();
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            addAutomaticKeepAlives: true,
                            addRepaintBoundaries: false,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.channels.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            itemBuilder: (context, index) {
                              final channel = widget.channels[index];

                              return ChannelCard(
                                tvPlayerBloc: tvPlayerBloc,
                                channel: channel,
                                focusNode: widget.focusNodes.isNotEmpty ? widget.focusNodes[index] : null,
                                index: index + 1,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
