import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/app_dialog.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/show_app_dialog.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/enum_widgets.dart';

void authListener(BuildContext context, AuthState state, AuthBloc block) {
  if (state is AuthStateLoaded) {
    if (state.status == AuthStatus.errorServiceExpired) {
      showAppDialog(
          context: context,
          appDialog: AppDialog(
            typeDialog: AppDialogType.ERROR,
            title: 'Error',
            description: state.message ?? "Algo salio mal",
            functionOk: () async {
              block.add(AuthEvent.logout());
            },
            functionCancel: null,
          ));
    }
    if (state.status == AuthStatus.loadingLogout) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.status == AuthStatus.logoutSuccess) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.inicioRoute, (route) => false);
    }
  }
}
