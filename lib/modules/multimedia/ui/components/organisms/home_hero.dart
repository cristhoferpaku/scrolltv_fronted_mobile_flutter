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
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class HomeHero extends StatefulWidget {
  final VideoModel video;
  final bool detailsDisabled;
  final double? height;
  const HomeHero({
    super.key,
    required this.video,
    this.detailsDisabled = false,
    this.height,
  });

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  final bool isTV = PlatformUtils.isTV;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 1.sh,
      child: Stack(
        clipBehavior: Clip.none,
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
          Positioned.fill(
            child: Column(
              spacing: AppPadding.p16,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: ColorManager.transparent,
                  height: 120,
                ),
                VideoMetadata(
                  section: widget.video.collectionName ?? "No collection name",
                  year: widget.video.year ?? "No year",
                  duration: widget.video.duration ?? "No duration",
                  genre: widget.video.categories ?? "No genre",
                ),
                SizedBox(
                  width: isTV ? .4.sw : double.infinity,
                  child: Text(
                    widget.video.description ?? "No description",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorManager.onSurface,
                        ),
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
                          textStyleButton:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
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
        ],
      ),
    );
  }
}
