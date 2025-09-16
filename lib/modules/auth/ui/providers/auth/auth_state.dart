part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loaded({required AuthStatus status, String? message}) = AuthStateLoaded;
}

enum AuthStatus {
  loading,
  loadingLogout,
  loaded,
  error,
  validateExpirationError,
  logoutError,
  errorServiceExpired,
  logoutSuccess,
}
