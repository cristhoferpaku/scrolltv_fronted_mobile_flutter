import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _timer;

  AuthBloc() : super(_Initial()) {
    final AuthUseCase authUseCase = instance<AuthUseCase>();
    final UserRepository userRepository = instance<UserRepository>();

    on<AuthEvent>((event, emit) {});
    on<_AuthEventStartValidate>((event, emit) {
      add(_AuthEventValidateExpiration());
      _startExpirationTimer();
    });

    on<_AuthEventStopValidate>((event, emit) {
      _stopExpirationTimer();
    });
    on<_AuthEventValidateExpiration>((event, emit) async {
      emit(AuthState.loaded(status: AuthStatus.loading));
      try {
        final deviceId = await userRepository.getDeviceId() ?? "";
        final response = await authUseCase.validateServiceExpiration(deviceId);

        if (response.success == true) {
          emit(AuthState.loaded(status: AuthStatus.loaded));
        } else {
          emit(AuthState.loaded(status: AuthStatus.errorServiceExpired, message: response.message));
        }
      } catch (e) {
        emit(AuthState.loaded(status: AuthStatus.errorServiceExpired, message: e.toString()));
      }
    });

    on<_AuthEventLogout>((event, emit) async {
      add(_AuthEventStopValidate());
      emit(AuthState.loaded(status: AuthStatus.loadingLogout));
      try {
        await authUseCase.logout();
        await userRepository.logoutUser();
        emit(AuthState.loaded(status: AuthStatus.logoutSuccess));
      } catch (e) {
        LoggerManager.log.i(e.toString());
        await userRepository.logoutUser();
        emit(AuthState.loaded(status: AuthStatus.logoutError));
      } finally {
        instance.popScope();
      }
    });
  }

  void _startExpirationTimer() {
    _stopExpirationTimer(); // evita duplicados
    _timer = Timer.periodic(const Duration(hours: 1), (_) {
      add(const AuthEvent.validateExpiration());
    });

    // Si quieres validar inmediatamente al iniciar:
    add(const AuthEvent.validateExpiration());
  }

  void _stopExpirationTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopExpirationTimer();
    return super.close();
  }
}
