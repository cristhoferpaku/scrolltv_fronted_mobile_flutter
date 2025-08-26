part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loaded(
      {required ProfileStatus status, UserModel? user}) = ProfileLoaded;
}

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
  logoutSuccess,
}
