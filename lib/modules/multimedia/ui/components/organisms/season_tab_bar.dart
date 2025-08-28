import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/season_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/episode_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar_normal.dart';

class SeasonTabBar extends StatelessWidget {
  final List<SeasonModel> seasons;
  const SeasonTabBar({
    super.key,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240.r,
      child: CustomTabBarNormal(
        items: [
          ...List.generate(
            seasons.length,
            (index) => CustomTabBarItem(
              title: "Temporada ${index + 1}",
              child: EpisodeCardList(episodes: seasons[index].episodes!),
            ),
          ),
        ],
        titleBar: Text(""),
      ),
    );
  }
}
