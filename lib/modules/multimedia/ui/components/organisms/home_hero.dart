import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/background_image.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/linear_gradient_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_metadata.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: isTV ? 1.sh : .8.sh,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackgroundImage(
            networkImage:
                isTV ? widget.video.bannerImage : widget.video.coverImage,
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
              top: AppPadding.p0.r,
              left: AppPadding.p0.r,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: ColorManager.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          Positioned.fill(
            child: FocusTraversalGroup(
              policy: CustomGridTraversalPolicyStrictVertical(),
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
                      "Intensamente 2: Las aventuras de rayli y sus emociones",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: ColorManager.onSurface,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  VideoMetadata(
                    section: widget.video.collectionName ?? "No data",
                    year: widget.video.year ?? "2024",
                    duration: widget.video.duration ?? "No data",
                    genre: widget.video.categories ?? "No data",
                  ),
                  SizedBox(
                    width: isTV ? .4.sw : double.infinity,
                    child: Text(
                      widget.video.description ?? "No description",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorManager.onSurface,
                            overflow: TextOverflow.ellipsis,
                          ),
                      maxLines: 7,
                    ),
                  ),
                  Row(
                    spacing: AppPadding.p16,
                    children: [
                      ContainerFocus(
                        borderRadius: 999,
                        child: ElevatedButtonApp(
                          iconData: Icon(Icons.play_arrow,
                              size: ResponsiveUtils.getIconSize(context)),
                          isExpanded: false,
                          textButton: AppString.buttonWatchNow,
                          colorButton: ColorManager.primaryContainer,
                          textStyleButton:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: ColorManager.onPrimaryContainer,
                                  ),
                          roundedButton: AppSize.s400,
                          press: () async {
                            Navigator.pushNamed(context, Routes.videoRoute);
                          },
                        ),
                      ),
                      if (!widget.detailsDisabled)
                        ContainerFocus(
                          borderRadius: 999,
                          child: ElevatedButtonApp(
                            iconData: Icon(Icons.info_outline,
                                size: ResponsiveUtils.getIconSize(context)),
                            isExpanded: false,
                            textButton: AppString.buttonDetails,
                            colorButton: ColorManager.transparent,
                            colorBorder: ColorManager.primaryContainer,
                            textStyleButton: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: ColorManager.onPrimaryContainer,
                                ),
                            roundedButton: AppSize.s400,
                            press: () async {
                              Navigator.pushNamed(
                                  context, Routes.videoDetailsRoute);
                            },
                          ),
                        ),
                    ],
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
