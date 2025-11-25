import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/components/organisms/login_form.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
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
      padding: AppPadding.p0,
      color: ColorManager.surfaceContainerLowest,
      body: Stack(children: [
        BlurBackground(
          top: 0,
          left: 0,
          width: 300,
          height: 300,
          offset: Offset(-100, 0),
        ),
        BlurBackground(
          right: 0,
          bottom: 0,
          width: 300,
          height: 300,
          offset: Offset(100, 0),
        ),
        Positioned.fill(
          child: LoginForm(formKey: formKey, loginBloc: loginBloc, tcUsername: tcUsername, tcPassword: tcPassword).withPadding(horizontal: AppPadding.p16, bottom: AppPadding.p16),
        ),
      ]),
    );
  }
}
