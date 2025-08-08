import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/colors.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
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
      backgroundImage: ImageAssets.backgroundTv,
      linearGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withValues(alpha: 0.85),
          Colors.black.withValues(alpha: 0.80),
          Colors.black.withValues(alpha: 0.5),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              spacing: AppSize.s90,
              children: [
                Expanded(
                  child: Container(
                    height: 620,
                    decoration: BoxDecoration(
                      color: ColorManager.surfaceDim,
                    ),
                    child: Center(
                      child: Text('Login Page'),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: AppSize.s24,
                    children: [
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
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ).withPadding(all: AppPadding.p24),
      ),
    );
  }
}
