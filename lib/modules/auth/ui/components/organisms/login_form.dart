import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/constants/schemas/validator_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/constants/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_listener.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/input/input_icon_form_field_small.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.loginBloc,
    required this.tcUsername,
    required this.tcPassword,
  });

  final GlobalKey<FormState> formKey;
  final LoginBloc loginBloc;
  final TextEditingController tcUsername;
  final TextEditingController tcPassword;

  @override
  Widget build(BuildContext context) {
    final bool isTV = PlatformUtils.isTV;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: BlocConsumer<LoginBloc, LoginState>(
        bloc: loginBloc,
        listener: (context, state) {
          loginListener(context, state);
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    spacing: AppSize.s24,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppSize.s24,
                        children: [
                          if (!isTV)
                            Image(image: AssetImage(ImageAssets.logoScrollTv)),
                          TextFormFieldIconSmall(
                            onChanged: (value) {},
                            controller: tcUsername,
                            validatorFunction:
                                ValidatorManager.validateUsername,
                            label: AppStringAuth.loginFormUsername,
                            hint: AppStringAuth.loginFormUsernameHint,
                          ),
                          TextFormFieldIconSmall(
                            onChanged: (value) {},
                            controller: tcPassword,
                            validatorFunction:
                                ValidatorManager.validatePassword,
                            label: AppStringAuth.loginFormPassword,
                            hint: AppStringAuth.loginFormPasswordHint,
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
                        press: () async {
                          if (formKey.currentState!.validate()) {
                            loginBloc.add(
                              LoginEvent.login(
                                  tcUsername.text, tcPassword.text),
                            );
                          }
                        },
                      )
                    ],
                  )),
            ],
          );
        },
      ).withPadding(top: AppPadding.p120),
    );
  }
}
