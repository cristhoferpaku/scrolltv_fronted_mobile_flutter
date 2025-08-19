import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/top_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class TopCardList extends StatefulWidget {
  final List<VideoModel> videos;
  const TopCardList({
    super.key,
    required this.videos,
  });

  @override
  State<TopCardList> createState() => _TopCardListState();
}

class _TopCardListState extends State<TopCardList> {
  final bool isTV = PlatformUtils.isTV;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: CustomGridTraversalPolicy(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppPadding.p16,
        children: [
          Text(
            "Top streaming",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: isTV ? AppPadding.p36 : AppPadding.p16,
              children: widget.videos
                  .map((video) => TopCard(
                      title: video.title ?? "",
                      topNumber: video.topNumber ?? 0,
                      coverImage: video.coverImage ?? ""))
                  .toList(),
            ).withPadding(
                vertical: AppPadding.p16,
                left: isTV ? AppPadding.p16 : AppPadding.p0),
          )
        ],
      ),
    );
  }
}
