import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response.freezed.dart';
part 'token_response.g.dart';

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    @JsonKey(name: "accessToken") String? accessToken,
    @JsonKey(name: "refreshToken") String? refreshToken,
    @JsonKey(name: "expiresIn") int? expiresIn,
    @JsonKey(name: "refreshExpiresIn") int? refreshExpiresIn,
    @JsonKey(name: "tokenType") String? tokenType,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
