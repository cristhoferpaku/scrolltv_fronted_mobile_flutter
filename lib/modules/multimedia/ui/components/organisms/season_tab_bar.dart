import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/season_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/cast_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/episode_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar_normal.dart';

class SeasonTabBar extends StatefulWidget {
  final List<SeasonModel> seasons;
  const SeasonTabBar({
    super.key,
    required this.seasons,
  });

  @override
  State<SeasonTabBar> createState() => _SeasonTabBarState();
}

class _SeasonTabBarState extends State<SeasonTabBar> {
  final FocusNode focusNodeSeasonTabBar = FocusNode();
  @override
  Widget build(BuildContext context) {
    if (widget.seasons.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 360.r,
      child: FocusTraversalGroup(
        policy: CustomGridSectionHorizontal(),
        child: Focus(
          focusNode: focusNodeSeasonTabBar,
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Scrollable.ensureVisible(
                  focusNodeSeasonTabBar.context!,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: 0.5,
                );
              });
            }
          },
          child: CustomTabBarNormal(
            items: [
              ...List.generate(
                widget.seasons.length,
                (index) => CustomTabBarItem(
                  title: "Temporada ${index + 1}",
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppPadding.p16.r,
                    children: [
                      Expanded(
                        child: EpisodeCardList(
                          episodes: widget.seasons[index].episodes!,
                          seasonId: widget.seasons[index].seasonId ?? 0,
                        ),
                      ),
                      if (widget.seasons[index].casts?.isNotEmpty ?? false) CastCardList(casts: widget.seasons[index].casts!, disabledEnsureVisible: true),
                    ],
                  ),
                ),
              ),
            ],
            titleBar: Text(""),
          ),
        ),
      ),
    );
  }
}
