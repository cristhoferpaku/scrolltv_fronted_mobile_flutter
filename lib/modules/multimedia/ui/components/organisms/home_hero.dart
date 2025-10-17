import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/background_image.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/linear_gradient_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_metadata.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class HomeHero extends StatefulWidget {
  final VideoModel video;
  final bool detailsDisabled;
  final double? height;
  final bool goBack;
  const HomeHero({
    super.key,
    required this.video,
    this.detailsDisabled = false,
    this.height,
    this.goBack = false,
  });

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  final bool isTV = PlatformUtils.isTV;

  double get height => isTV ? 1.sh : .8.sh;
  double get minHeight => 500.r;
  @override
  Widget build(BuildContext context) {
    if (widget.video.id == null) return NoContentBox(height: 1.sh);
    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackgroundImage(
            networkImage: isTV ? widget.video.bannerImage : widget.video.coverImage,
            fit: BoxFit.cover,
          ),
          LinearGradientBox(
            colors: ValuesManager.heroLinearGradientColors,
            stops: ValuesManager.heroLinearGradientStops,
            begin: ValuesManager.heroLinearGradientBegin,
            end: ValuesManager.heroLinearGradientEnd,
          ),
          if (widget.goBack)
            Positioned(
              top: AppPadding.p16,
              left: AppPadding.p16,
              child: ContainerFocus(
                autofocus: isTV ? true : false,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: ColorManager.white).withPadding(
                  vertical: AppPadding.p8,
                  right: AppPadding.p8,
                  left: isTV ? AppPadding.p8 : null,
                ),
              ),
            ),
          Positioned.fill(
            child: FocusTraversalGroup(
              child: Column(
                spacing: AppPadding.p16,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: ColorManager.transparent,
                    height: 120,
                  ),
                  SizedBox(
                    width: isTV ? .4.sw : double.infinity,
                    child: Text(
                      widget.video.title ?? "Sin título",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: ColorManager.onSurface,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  VideoMetadata(
                    section: widget.video.collectionName ?? "Sin sección",
                    year: widget.video.year?.toString() ?? "Sin año",
                    duration: widget.video.duration ?? "Sin duración",
                    genre: widget.video.categories ?? "Sin género",
                  ),
                  SizedBox(
                    width: isTV ? .4.sw : double.infinity,
                    child: Text(
                      widget.video.description ?? "Sin descripción",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorManager.onSurface,
                            overflow: TextOverflow.ellipsis,
                          ),
                      maxLines: 7,
                    ),
                  ),
                  Focus(
                    canRequestFocus: false,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent || event is KeyRepeatEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          Actions.invoke(context, const DirectionalFocusIntent(TraversalDirection.down));
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: FocusTraversalGroup(
                      policy: CustomGridSectionHorizontal(),
                      child: Row(
                        spacing: AppPadding.p16,
                        children: [
                          ContainerFocus(
                            borderRadius: 999,
                            child: ElevatedButtonApp(
                              iconData: Icon(Icons.play_arrow, size: ResponsiveUtils.getIconSize(context)),
                              isExpanded: false,
                              textButton: AppString.buttonWatchNow,
                              colorButton: ColorManager.primaryContainer,
                              textStyleButton: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: ColorManager.onPrimaryContainer,
                                  ),
                              roundedButton: AppSize.s400,
                              press: () {
                                Navigator.pushNamed(context, Routes.videoRoute,
                                    arguments: VideoPageArguments(
                                      videoId: widget.video.id ?? 0,
                                      videoUrl: widget.video.videoUrl ?? "",
                                      seasonId: widget.video.firstSeasonId ?? 0,
                                      episodeNumber: widget.video.firstEpisodeNumber ?? 0,
                                      type: widget.video.type ?? "movie",
                                    ));
                              },
                            ),
                          ),
                          if (!widget.detailsDisabled)
                            ContainerFocus(
                              borderRadius: 999,
                              child: ElevatedButtonApp(
                                iconData: Icon(Icons.info_outline, size: ResponsiveUtils.getIconSize(context)),
                                isExpanded: false,
                                textButton: AppString.buttonDetails,
                                colorButton: ColorManager.transparent,
                                colorBorder: ColorManager.primaryContainer,
                                textStyleButton: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: ColorManager.onPrimaryContainer,
                                    ),
                                roundedButton: AppSize.s400,
                                press: () async {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.videoDetailsRoute,
                                    arguments: VideoDetailsPageArguments(
                                      videoId: widget.video.id ?? 0,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).withPadding(all: AppPadding.p16),
            ),
          ),
        ],
      ),
    );
  }
}
