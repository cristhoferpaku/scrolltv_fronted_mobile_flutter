import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/input/input_icon_form_field_small.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: AppPadding.p0,
      color: ColorManager.surfaceContainerLowest,
      body: Stack(children: [
        Positioned(
          top: 50,
          left: 30,
          child: Transform.translate(
            offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: ColorManager.primary300.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 30,
          child: Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: ColorManager.primary300.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            spacing: AppSize.s24,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSize.s24,
                children: [
                  Image(image: AssetImage(ImageAssets.logoScrollTv)),
                  TextFormFieldIconSmall(
                    onChanged: (value) {},
                    controller: controller,
                    validatorFunction: (value) {},
                    label: "Cuenta",
                    hint: "Uisesxs31",
                  ),
                  TextFormFieldIconSmall(
                    onChanged: (value) {},
                    controller: controller,
                    validatorFunction: (value) {},
                    label: "Contraseña",
                    hint: "••••••••••••",
                    isPassword: true,
                    rightIcon: Icons.remove_red_eye,
                  ),
                ],
              ),
              ElevatedButtonApp(
                isExpanded: false,
                textButton: AppString.loginButton,
                colorButton: ColorManager.primaryContainer,
                textStyleButton:
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ColorManager.onPrimaryContainer,
                        ),
                roundedButton: AppSize.s10,
                press: () {},
              )
            ],
          ).withPadding(top: AppPadding.p120),
        ).withPadding(horizontal: AppPadding.p16, bottom: AppPadding.p16),
      ]),
    );
  }
}
