import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository = instance<UserRepository>();

  ProfileBloc() : super(_Initial()) {
    on<ProfileEvent>((event, emit) {});
    on<_ProfileEventLogout>((event, emit) async {
      await _userRepository.logoutUser();
      emit(const ProfileState.loaded(ProfileStatus.logoutSuccess));
    });
  }
}
