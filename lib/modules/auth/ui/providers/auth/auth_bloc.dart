import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(_Initial()) {
    final AuthUseCase authUseCase = instance<AuthUseCase>();
    final UserRepository userRepository = instance<UserRepository>();
    on<AuthEvent>((event, emit) {});
    on<_AuthEventValidateExpiration>((event, emit) async {
      emit(AuthState.loaded(status: AuthStatus.loading));
      try {
        final response = await authUseCase.validateServiceExpiration();

        if (response.success == true) {
          emit(AuthState.loaded(status: AuthStatus.loaded));
        } else {
          emit(AuthState.loaded(status: AuthStatus.errorServiceExpired, message: response.message));
        }
      } catch (e) {
        emit(AuthState.loaded(status: AuthStatus.error, message: e.toString()));
      }
    });

    on<_AuthEventLogout>((event, emit) async {
      emit(AuthState.loaded(status: AuthStatus.loadingLogout));
      try {
        await authUseCase.logout();
        await userRepository.logoutUser();
        emit(AuthState.loaded(status: AuthStatus.logoutSuccess));
      } catch (e) {
        emit(AuthState.loaded(status: AuthStatus.error, message: e.toString()));
      }
    });
  }
}
