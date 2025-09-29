part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = _Started;
  const factory AuthEvent.validateExpiration() = _AuthEventValidateExpiration;
  const factory AuthEvent.logout() = _AuthEventLogout;
  const factory AuthEvent.startValidate() = _AuthEventStartValidate;
  const factory AuthEvent.stopValidate() = _AuthEventStopValidate;
}
