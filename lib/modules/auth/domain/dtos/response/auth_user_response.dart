import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/token_response.dart';

part 'auth_user_response.freezed.dart';
part 'auth_user_response.g.dart';

@freezed
class AuthUserResponse with _$AuthUserResponse {
  const factory AuthUserResponse({
    @JsonKey(name: "username") String? username,
    @JsonKey(name: "password") String? password,
    @JsonKey(name: "tokens") TokenResponse? tokens,
  }) = _AuthUserResponse;

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthUserResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
