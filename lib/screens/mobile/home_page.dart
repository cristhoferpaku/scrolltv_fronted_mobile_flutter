import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';

import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: AppPadding.p0,
      body: Column(
        spacing: AppPadding.p16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: HomeNavbar(),
          ),
        ],
      ),
    );
  }
}

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
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageAssets.backgroundMobile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.16),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            spacing: AppPadding.p16,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: AppPadding.p4,
                children: [
                  ElevatedButtonApp(
                    paddingHorizontal: 8,
                    paddingVertical: 4,
                    isExpanded: false,
                    textButton: "Netflix",
                    colorButton: ColorManager.transparent,
                    colorBorder: ColorManager.onSurface,
                    textStyleButton:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ColorManager.onSurface,
                            ),
                    roundedButton: AppSize.s200,
                    press: () async {},
                  ),
                  CircleAvatar(
                    radius: 2,
                    backgroundColor: ColorManager.neutro200,
                  ),
                  Text(
                    "2023",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ColorManager.onSurface,
                        ),
                  ),
                  CircleAvatar(
                    radius: 2,
                    backgroundColor: ColorManager.neutro200,
                  ),
                  Text(
                    "2h 30m",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ColorManager.onSurface,
                        ),
                  ),
                  CircleAvatar(
                    radius: 2,
                    backgroundColor: ColorManager.neutro200,
                  ),
                  Text(
                    "Acción/fantasia",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ColorManager.onSurface,
                        ),
                  ),
                ],
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
