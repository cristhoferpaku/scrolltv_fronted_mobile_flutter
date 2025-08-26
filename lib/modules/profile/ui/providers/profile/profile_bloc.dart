import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';

import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/inbound/user_use_case.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository = instance<UserRepository>();
  final UserUseCase _userUseCase = instance<UserUseCase>();

  UserModel? user;
  ProfileBloc() : super(const _Initial()) {
    on<ProfileEvent>((event, emit) {});

    on<_ProfileEventStarted>((event, emit) async {
      try {
        int id = int.tryParse(await _userRepository.getUserId()) ?? 0;
        final userResponse = await _userUseCase.getById(id);
        final user = userResponse.data;
        emit(ProfileState.loaded(status: ProfileStatus.loaded, user: user));
      } catch (e) {
        emit(ProfileState.loaded(status: ProfileStatus.error, user: user));
      }
    });
    on<_ProfileEventLogout>((event, emit) async {
      await _userRepository.logoutUser();
      emit(
          ProfileState.loaded(status: ProfileStatus.logoutSuccess, user: user));
    });
  }
}
