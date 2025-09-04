import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/inbound/user_use_case.dart';

part 'profile_bloc.freezed.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository = instance<UserRepository>();
  final UserUseCase _userUseCase = instance<UserUseCase>();
  final AuthUseCase _authUseCase = instance<AuthUseCase>();

  UserModel? user;
  String? firstLetterUsername;
  ProfileBloc() : super(const _Initial()) {
    on<ProfileEvent>((event, emit) {});

    on<_ProfileEventStarted>((event, emit) async {
      emit(ProfileState.loaded(status: ProfileStatus.loading, user: user));
      try {
        int id = int.tryParse(await _userRepository.getUserId()) ?? 0;

        if (user == null) {
          final userResponse = await _userUseCase.getById(id);
          user = userResponse.data;
          firstLetterUsername = user?.username?.substring(0, 1).toUpperCase();
        }
        emit(ProfileState.loaded(status: ProfileStatus.loaded, user: user, firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(ProfileState.loaded(status: ProfileStatus.error, user: user, firstLetterUsername: firstLetterUsername));
      }
    });
    on<_ProfileEventLogout>((event, emit) async {
      try {
        await _authUseCase.logout();
        await _userRepository.logoutUser();
        emit(ProfileState.loaded(status: ProfileStatus.logoutSuccess, user: user, firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(ProfileState.loaded(status: ProfileStatus.error, user: user, firstLetterUsername: firstLetterUsername));
      }
    });
  }
}
