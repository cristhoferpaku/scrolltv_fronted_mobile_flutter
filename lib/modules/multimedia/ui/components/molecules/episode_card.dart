import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/linear_gradient_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class EpisodeCard extends StatelessWidget {
  final int seasonId;
  final EpisodeModel episode;
  const EpisodeCard({
    super.key,
    required this.episode,
    required this.seasonId,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: () {
        Navigator.pushNamed(context, Routes.videoRoute, arguments: VideoPageArguments(videoId: 0, videoUrl: episode.videoUrl ?? "", episodeNumber: episode.episodeNumber ?? 0, seasonId: seasonId));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppSize.s16.r,
              ),
              border: Border.all(
                color: ColorManager.white.withValues(alpha: 0.2),
                width: AppSize.s2.r,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            width: 300.r,
            height: 190.r,
            child: ImageWithPlaceholder(imageUrl: episode.coverImage ?? ""),
          ),
          Positioned.fill(
            child: LinearGradientBox(
              colors: [
                Colors.black.withValues(alpha: 1),
                Colors.black.withValues(alpha: 0),
              ],
              stops: [0.0, 1.0],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          Positioned(
            left: 8.r,
            bottom: 8.r,
            child: Text("Ep ${episode.episodeNumber}"),
          ),
        ],
      ),
    );
  }
}
