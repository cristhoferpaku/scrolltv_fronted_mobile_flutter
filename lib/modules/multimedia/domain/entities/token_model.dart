import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

@freezed
class TokenModel with _$TokenModel {
  const factory TokenModel({
    @JsonKey(name: "accessToken") String? accessToken,
    @JsonKey(name: "refreshToken") String? refreshToken,
    @JsonKey(name: "expiresIn") int? expiresIn,
    @JsonKey(name: "refreshExpiresIn") int? refreshExpiresIn,
    @JsonKey(name: "tokenType") String? tokenType,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
