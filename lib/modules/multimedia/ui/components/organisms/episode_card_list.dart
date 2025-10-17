import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/episode_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class EpisodeCardList extends StatefulWidget {
  final int seasonId;
  final List<EpisodeModel> episodes;
  const EpisodeCardList({
    super.key,
    required this.episodes,
    required this.seasonId,
  });

  @override
  State<EpisodeCardList> createState() => _EpisodeCardListState();
}

class _EpisodeCardListState extends State<EpisodeCardList> {
  List<FocusNode> focusNodes = [];
  FocusNode focusNodeEpisodeList = FocusNode();
  int _lastFocusIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (focusNodes.isEmpty || focusNodes.length != widget.episodes.length) {
      focusNodes = List.generate(widget.episodes.length, (index) => FocusNode());
    }
    return Focus(
      focusNode: focusNodeEpisodeList,
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          FocusScope.of(context).requestFocus(focusNodes[_lastFocusIndex]);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNodeEpisodeList.context != null) {
              Scrollable.ensureVisible(
                focusNodeEpisodeList.context!,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                alignment: 0.5,
              );
            }
          });
        }
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (focusNodes.first.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            return KeyEventResult.handled;
          }
          if (focusNodes.last.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowRight) {
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
      child: FocusTraversalGroup(
        policy: CustomGridSectionHorizontal(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppPadding.p16.r,
            children: [
              ...List.generate(
                widget.episodes.length,
                (index) => Focus(
                  canRequestFocus: false,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (hasFocus) {
                          _lastFocusIndex = index;
                        }
                      });
                    }
                  },
                  child: EpisodeCard(seasonId: widget.seasonId, episode: widget.episodes[index], focusNode: focusNodes[index]),
                ),
              ),
            ],
          ).withPadding(top: AppPadding.p16.r),
        ),
      ),
    );
  }
}
