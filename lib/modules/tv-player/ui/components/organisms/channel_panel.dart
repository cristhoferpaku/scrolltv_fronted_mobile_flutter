import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_category_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/organisms/channel_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';

class ChannelPanel extends StatefulWidget {
  const ChannelPanel({
    super.key,
  });

  @override
  State<ChannelPanel> createState() => _ChannelPanelState();
}

class _ChannelPanelState extends State<ChannelPanel> {
  final TvPlayerBloc livePlayerBloc = instance<TvPlayerBloc>();
  List<FocusNode> focusNodes = [];
  List<FocusNode> focusNodeChannelList = [];

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(livePlayerBloc.state.categories.length, (_) => FocusNode());
    focusNodeChannelList = List.generate(livePlayerBloc.state.categories.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var node in focusNodeChannelList) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvPlayerBloc, TvPlayerState>(
      bloc: livePlayerBloc,
      builder: (context, state) {
        if (focusNodes.length != state.categories.length) {
          for (var n in focusNodes) {
            n.dispose();
          }
          focusNodes = List.generate(state.categories.length, (_) => FocusNode());
        }
        if (focusNodeChannelList.length != state.channels.length) {
          for (var n in focusNodeChannelList) {
            n.dispose();
          }
          focusNodeChannelList = List.generate(state.channels.length, (_) => FocusNode());
        }
        return Stack(
          children: [
            // Fondo con gradiente (ocupa toda la pantalla)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              top: 0,
              right: state.showChannelList ? 0 : MediaQuery.of(context).size.width,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorManager.neutro900.withOpacity(0.98),
                      ColorManager.neutro900.withOpacity(0.18),
                    ],
                  ),
                ),
              ),
            ),

            // Panel de 400 px sobre el gradiente
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: state.showChannelList ? 0 : -600,
              top: 0,
              bottom: 0,
              width: 600,
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    if (state.showChannelList) {
                      return KeyEventResult.ignored;
                    } else {
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Row(
                  children: [
                    Expanded(
                      child: ChannelCategoryList(
                        selectedCategoryIndex: state.selectedCategoryIndex,
                        categories: state.categories,
                        focusNodes: focusNodes,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ChannelList(channels: state.channels, focusNodes: focusNodeChannelList),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
