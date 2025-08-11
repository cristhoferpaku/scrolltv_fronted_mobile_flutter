import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(_Initial()) {
    final authUseCase = instance<AuthUseCase>();
    on<LoginEvent>((event, emit) {});
    on<LoginEventLogin>((event, emit) async {
      try {
        final user =
            LoginModel(username: event.username, password: event.password);

        final response = await authUseCase.login(user);
        emit(LoginState.success());
      } catch (e) {
        emit(LoginState.error(e.toString()));
      }
    });
  }
}
