import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/app_dialog_customize.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/show_app_dialog.dart';

void authListener(BuildContext context, AuthState state, AuthBloc block) {
  if (state is AuthStateLoaded) {
    if (state.status == AuthStatus.errorServiceExpired) {
      showAppDialog(
          context: navigatorKey.currentContext!,
          appDialog: AppDialogCustomize(
            type: AppDialogCustomizeType.error,
            message: state.message ?? "Algo salio mal",
            onPressed: () async {
              block.add(AuthEvent.logout());
            },
            labelActionButton: "Aceptar",
            iconActionButton: Icons.check,
            showCancelButton: false,
          ));
    }
    if (state.status == AuthStatus.loadingLogout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (context) => const Material(
            type: MaterialType.transparency,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
    }
    if (state.status == AuthStatus.logoutSuccess) {
      Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, Routes.inicioRoute, (route) => false);
    }
    if (state.status == AuthStatus.logoutError) {
      Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, Routes.inicioRoute, (route) => false);
    }
    if (state.status == AuthStatus.error) {
      showAppDialog(
          context: navigatorKey.currentContext!,
          appDialog: AppDialogCustomize(
            type: AppDialogCustomizeType.error,
            message: state.message ?? "Algo salio mal",
            onPressed: () async {
              Navigator.pop(navigatorKey.currentContext!);
            },
            labelActionButton: "Aceptar",
            iconActionButton: Icons.check,
            showCancelButton: false,
          ));
    }
  }
}
