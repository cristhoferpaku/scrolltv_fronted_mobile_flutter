import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';

void loginListener(BuildContext context, LoginState state) {
  if (state is LoginStateLoading) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  } else if (state is LoginStateError) {
    // Cerrar solo el dialog de loading si está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: const Color.fromARGB(29, 0, 4, 255),
        duration: const Duration(seconds: 4),
      ),
    );
  } else if (state is LoginStateSuccess) {
    // Cerrar el dialog de loading si está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushNamedAndRemoveUntil(context, Routes.homeRoute, (route) => false);
  }
}
