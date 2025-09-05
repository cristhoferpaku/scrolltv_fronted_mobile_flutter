import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/episode_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class EpisodeCardList extends StatelessWidget {
  final int seasonId;
  final List<EpisodeModel> episodes;
  const EpisodeCardList({
    super.key,
    required this.episodes,
    required this.seasonId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppPadding.p16.r,
        children: [
          ...List.generate(
            episodes.length,
            (index) => EpisodeCard(seasonId: seasonId, episode: episodes[index]),
          ),
        ],
      ).withPadding(top: AppPadding.p16.r),
    );
  }
}
