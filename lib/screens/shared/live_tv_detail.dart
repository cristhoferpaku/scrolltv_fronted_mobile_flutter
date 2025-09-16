import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_panel.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_view.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/constants/focus_enum.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class LiveTvDetail extends StatefulWidget {
  const LiveTvDetail({super.key});

  @override
  State<LiveTvDetail> createState() => _LiveTvDetailState();
}

class _LiveTvDetailState extends State<LiveTvDetail> {
  final livePlayerBloc = instance<TvPlayerBloc>();
  bool showChannelList = false;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final bool isTv = PlatformUtils.isTV;

  bool isLandscape = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as LiveTvDetailArguments;

      if (arguments.showChannelList && isTv) {
        livePlayerBloc.add(TvPlayerEvent.showPanelChannelByHome());
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return WillPopScope(
      onWillPop: () async {
        // Se llama cuando el usuario intenta salir (back button o swipe)
        if (livePlayerBloc.state.showChannelList) {
          livePlayerBloc.add(TvPlayerEvent.showPanelChannel(false));
          return false; // bloqueamos el pop
        } else {
          return true; // dejamos que la pantalla haga pop
        }
      },
      child: Material(
        child: Focus(
          skipTraversal: true,
          autofocus: true,
          focusNode: _focusNode,
          onKeyEvent: (FocusNode node, event) {
            if (event is KeyDownEvent) {
              BuildContext? ctx = FocusManager.instance.primaryFocus?.context;
              while (ctx != null) {
                debugPrint('-> ${ctx.widget.runtimeType}');
                ctx = ctx.findAncestorStateOfType<State>()?.context;
              }
              if (livePlayerBloc.state.showChannelList) {
              } else {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  livePlayerBloc.add(TvPlayerEvent.showPanelChannel(true));
                  return KeyEventResult.ignored;
                }
                if (event.logicalKey == LogicalKeyboardKey.goBack) {
                  livePlayerBloc.add(TvPlayerEvent.showPanelChannel(false));

                  return KeyEventResult.ignored;
                }
                return KeyEventResult.skipRemainingHandlers;
              }
            }
            return KeyEventResult.ignored;
          },
          child: BlocConsumer<TvPlayerBloc, TvPlayerState>(
            bloc: livePlayerBloc,
            listener: (context, state) {
              if (state.focusEnum == FocusEnum.channelView) {
                _focusNode.requestFocus();
                return;
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Video Player Area
                  Column(
                    children: [
                      Expanded(child: ChannelView(selectedChannelIndex: state.selectedChannelIndex)),
                      if (!isLandscape && !isTv)
                        Expanded(
                            child: ChannelList(
                          channels: state.channels,
                          focusNodes: [],
                        )),
                    ],
                  ),

                  ChannelPanel(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
