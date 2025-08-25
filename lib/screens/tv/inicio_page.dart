import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/gradient_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundImage: ImageAssets.backgroundTv,
        linearGradient: GradientManager().background(),
        body: Container(
          constraints: BoxConstraints(
            minWidth: AppSize.s220,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(image: AssetImage(ImageAssets.logoScrollTv)),
              ElevatedButtonApp(
                isExpanded: false,
                textButton: AppString.iniciarSesion,
                colorButton: ColorManager.primary300,
                textStyleButton:
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ColorManager.onPrimaryDimFixed,
                        ),
                roundedButton: AppSize.s10,
                press: () {
                  Navigator.pushNamed(context, Routes.loginRoute);
                },
              ).withPadding(top: AppPadding.p20),
            ],
          ),
        ).withPadding(horizontal: AppPadding.p280));
  }
}
