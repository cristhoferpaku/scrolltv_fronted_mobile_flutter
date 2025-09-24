import 'package:freezed_annotation/freezed_annotation.dart';

part 'expiration_response.freezed.dart';
part 'expiration_response.g.dart';

@freezed
class ExpirationResponse with _$ExpirationResponse {
  factory ExpirationResponse({
    int? success,
    String? message,
  }) = _ExpirationResponse;

  factory ExpirationResponse.fromJson(Map<String, dynamic> json) => _$ExpirationResponseFromJson(json);
}
