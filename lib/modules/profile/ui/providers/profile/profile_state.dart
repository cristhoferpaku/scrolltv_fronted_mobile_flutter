part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loaded(ProfileStatus status) = ProfileLoaded;
}

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
  logoutSuccess,
}
