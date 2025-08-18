import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(_Initial()) {
    final authUseCase = instance<AuthUseCase>();
    on<LoginEvent>((event, emit) {});
    on<LoginEventLogin>((event, emit) async {
      try {
        emit(const LoginState.success());
        // final user =
        //     LoginModel(username: event.username, password: event.password);

        // final response = await authUseCase.login(user);
        // LoggerManager.log.i('Login response: $response');

        // if (response.success == true) {
        //   emit(LoginState.success());
        // } else {
        //   emit(LoginState.error('Error de autenticación'));
        // }
      } catch (e) {
        LoggerManager.log.e('Error en login: $e');

        // Extraer mensaje de error más limpio
        String errorMessage = 'Error inesperado durante el login';
        String fullError = e.toString();

        if (fullError.contains('Exception:')) {
          // Remover todas las ocurrencias de "Exception: " para evitar duplicación
          errorMessage = fullError.replaceAll('Exception: ', '').trim();

          // Si después de limpiar queda vacío, usar mensaje por defecto
          if (errorMessage.isEmpty) {
            errorMessage = 'Error inesperado durante el login';
          }
        } else {
          errorMessage = fullError;
        }

        emit(LoginState.error(errorMessage));
      }
    });
  }
}
