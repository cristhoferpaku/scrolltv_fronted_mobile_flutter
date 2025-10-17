import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/section_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class SectionCardList extends StatefulWidget {
  final int id;
  final String title;
  final bool hasBlurLeft;
  final bool hasBlurRight;
  final List<VideoModel> videos;
  const SectionCardList({
    super.key,
    required this.id,
    required this.title,
    this.hasBlurLeft = false,
    this.hasBlurRight = false,
    required this.videos,
  });

  @override
  State<SectionCardList> createState() => _SectionCardListState();
}

class _SectionCardListState extends State<SectionCardList> {
  bool isTV = PlatformUtils.isTV;
  FocusNode focusNodeCardList = FocusNode();
  List<FocusNode> focusNodes = [];
  int lastFocusindex = 0;

  @override
  Widget build(BuildContext context) {
    if (focusNodes.length != widget.videos.length) {
      for (var node in focusNodes) {
        node.dispose();
      }
      focusNodes = List.generate(widget.videos.length, (_) => FocusNode());
    }
    final isTV = PlatformUtils.isTV;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FocusTraversalGroup(
          policy: CustomGridSectionHorizontal(),
          child: Focus(
            focusNode: focusNodeCardList,
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Scrollable.ensureVisible(
                    focusNodeCardList.context!,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: 0.5,
                  );
                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppPadding.p16,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.collectionRoute, arguments: CollectionPageArguments(collectionId: widget.id, collectionName: widget.title));
                        },
                        child: Row(
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (!isTV)
                              IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Routes.collectionRoute, arguments: CollectionPageArguments(collectionId: widget.id, collectionName: widget.title));
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: ColorManager.onSurface,
                                    size: ResponsiveUtils.getIconSize(context),
                                  )),
                          ],
                        ),
                      ),
                    ),
                    if (isTV)
                      ElevatedButtonApp(
                        press: () {
                          Navigator.pushNamed(context, Routes.collectionRoute, arguments: CollectionPageArguments(collectionId: widget.id, collectionName: widget.title));
                        },
                        textStyleButton: Theme.of(context).textTheme.bodySmall,
                        textButton: 'Ver colección',
                        colorButton: ColorManager.transparent,
                        colorBorder: ColorManager.primaryContainer,
                        roundedButton: AppSize.s120,
                        paddingHorizontal: AppPadding.p40,
                        paddingVertical: AppPadding.p12,
                        widthBorder: 1.5,
                        isExpanded: false,
                      )
                  ],
                ),
                if (widget.videos.isEmpty)
                  NoContentBox()
                else
                  SizedBox(
                    height: 216.r,
                    child: Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          FocusScope.of(context).requestFocus(focusNodes[lastFocusindex]);
                        }
                      },
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.videos.length,
                        separatorBuilder: (context, index) => SizedBox(width: AppPadding.p16),
                        itemBuilder: (context, index) => Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (hasFocus) {
                                  lastFocusindex = index;
                                }
                              });
                            }
                          },
                          child: SectionCard(
                              focusNode: focusNodes[index],
                              title: widget.videos[index].title ?? "",
                              coverImage: widget.videos[index].coverImage ?? "",
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.videoDetailsRoute,
                                  arguments: VideoDetailsPageArguments(videoId: widget.videos[index].id ?? 0),
                                );
                              }),
                        ),
                      ),
                    ),
                  ).withPadding(vertical: AppPadding.p16, left: isTV ? AppPadding.p16 : AppPadding.p0),
              ],
            ),
          ),
        ),
        if (widget.hasBlurLeft)
          BlurBackground(
            top: 0,
            left: 0,
            offset: Offset(ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500) / 2 * -1, ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500) / 2 * -1),
            width: ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500),
            height: ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500),
          ),
        if (widget.hasBlurRight)
          BlurBackground(
            offset: Offset(ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500) / 2, ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500) / 2),
            bottom: 0,
            right: 0,
            width: ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500),
            height: ResponsiveUtils.getSize(context, minSize: 200, maxSize: 500),
          ),
      ],
    );
  }
}
