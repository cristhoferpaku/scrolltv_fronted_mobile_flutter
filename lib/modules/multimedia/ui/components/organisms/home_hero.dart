import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/background_image.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/linear_gradient_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_metadata.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class HomeHero extends StatefulWidget {
  const HomeHero({
    super.key,
  });

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BackgroundImage(
          image: ImageAssets.backgroundMobile,
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
                section: "Netflix",
                year: "2023",
                duration: "2h 30m",
                genre: "Acción/fantasia",
              ),
              Text(
                "Miles regresa para un nuevo capítulo de esta galardonada saga donde deberá reevaluar el significado de ser héroe cuando es obligado a enfrentar a todo un equipo de héroes arácnidos encargados de proteger la existencia misma del Multiverso.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorManager.onSurface,
                    ),
              ),
              Row(
                spacing: AppPadding.p16,
                children: [
                  ElevatedButtonApp(
                    iconData: const Icon(Icons.play_arrow),
                    isExpanded: false,
                    textButton: AppString.buttonWatchNow,
                    colorButton: ColorManager.primaryContainer,
                    textStyleButton:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: ColorManager.onPrimaryContainer,
                            ),
                    roundedButton: AppSize.s400,
                    press: () async {},
                  ),
                  ElevatedButtonApp(
                    iconData: const Icon(Icons.info_outline),
                    isExpanded: false,
                    textButton: AppString.buttonDetails,
                    colorButton: ColorManager.transparent,
                    colorBorder: ColorManager.primaryContainer,
                    textStyleButton:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: ColorManager.onPrimaryContainer,
                            ),
                    roundedButton: AppSize.s400,
                    press: () async {},
                  ),
                ],
              ),
            ],
          ).withPadding(all: AppPadding.p16),
        ),
      ],
    );
  }
}
