part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.started() = _ProfileEventStarted;
  const factory ProfileEvent.logout() = _ProfileEventLogout;
}
