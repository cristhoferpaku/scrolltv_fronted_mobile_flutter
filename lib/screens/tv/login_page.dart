import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/colors.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/components/organisms/login_form.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController tcUsername = TextEditingController();
  final TextEditingController tcPassword = TextEditingController();
  final loginBloc = instance<LoginBloc>();
  final formKey = GlobalKey<FormState>();
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
        child: Row(
          spacing: AppSize.s90,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Center(
                child: LoginForm(
                  formKey: formKey,
                  loginBloc: loginBloc,
                  tcUsername: tcUsername,
                  tcPassword: tcPassword,
                ),
              ),
            ),
          ],
        ).withPadding(all: AppPadding.p24),
      ),
    );
  }
}
