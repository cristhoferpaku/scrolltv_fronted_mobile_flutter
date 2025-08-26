import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/token_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/dtos/response/user_response.dart';

part 'auth_user_response.freezed.dart';
part 'auth_user_response.g.dart';

@freezed
class AuthUserResponse with _$AuthUserResponse {
  const factory AuthUserResponse({
    @JsonKey(name: "tokens") TokenResponse? tokens,
    @JsonKey(name: "user") UserResponse? user,
  }) = _AuthUserResponse;

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthUserResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// @freezed
// class UserModelResponse with _$UserModelResponse {
//   factory UserModelResponse({
//     int? id,
//     String? username,
//     int? status,
//     int? roleId,
//     String? roleName,
//   }) = _UserModelResponse;

//   factory UserModelResponse.fromJson(Map<String, dynamic> json) =>
//       _$UserModelResponseFromJson(json);
// }
