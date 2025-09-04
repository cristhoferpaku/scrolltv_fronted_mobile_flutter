import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class VideoCardList extends StatelessWidget {
  const VideoCardList({
    super.key,
    required this.videos,
    this.firstCardFocusNode,
    this.columns,
  });
  final int? columns;

  final List<VideoModel> videos;
  final FocusNode? firstCardFocusNode;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return NoContentBox();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: EdgeInsets.all(AppPadding.p16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns ?? (constraints.maxWidth / 140).floor(), // columnas
            crossAxisSpacing: AppPadding.p16,
            mainAxisSpacing: AppPadding.p16,
            childAspectRatio: 140.r / 200.r,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return VideoCard(
              title: videos[index].title ?? "",
              coverImage: videos[index].coverImage ?? "",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.videoDetailsRoute,
                  arguments: VideoDetailsPageArguments(videoId: videos[index].id ?? 0),
                );
              },
            );
          },
        );
      },
    );
  }
}

// VideoCard(
//                 focusNode: index == 0 ? firstCardFocusNode : null,
//                 title: videos[index].title ?? "",
//                 coverImage: videos[index].coverImage ?? "",
//                 onTap: () {
//                   print("index: $index");
//                   Navigator.pushNamed(
//                     context,
//                     Routes.videoDetailsRoute,
//                     arguments: VideoDetailsPageArguments(videoId: videos[index].id ?? 0),
//                   );
//                 },
//               );
