import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
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
  List<FocusNode> focusNodes = [];
  FocusNode focusNodeTopCardList = FocusNode();
  int lastFocusindex = 0;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(widget.videos.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: CustomGridSectionHorizontal(),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, spacing: AppPadding.p16, children: [
        Text(
          "Top streaming",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (widget.videos.isEmpty)
          NoContentBox()
        else
          Focus(
            focusNode: focusNodeTopCardList,
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                // Usar Future.delayed para esperar que Flutter haya renderizado
                FocusScope.of(context).requestFocus(focusNodes[lastFocusindex]);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (focusNodeTopCardList.context != null) {
                    Scrollable.ensureVisible(
                      focusNodeTopCardList.context!,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: 0.8,
                    );
                  }
                });
              }
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: isTV ? AppPadding.p36 : AppPadding.p16,
                children: widget.videos
                    .map((video) => Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (hasFocus) {
                                lastFocusindex = widget.videos.indexOf(video);
                              }
                            });
                          }
                        },
                        child: TopCard(
                          focusNode: focusNodes[widget.videos.indexOf(video)],
                          title: video.title ?? "",
                          topNumber: video.topNumber ?? 0,
                          coverImage: video.coverImage ?? "",
                          videoId: video.id ?? 0,
                        )))
                    .toList(),
              ).withPadding(vertical: AppPadding.p16, left: isTV ? AppPadding.p16 : AppPadding.p0),
            ),
          ),
      ]),
    );
  }
}
