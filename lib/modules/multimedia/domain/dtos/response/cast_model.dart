import 'package:freezed_annotation/freezed_annotation.dart';

part 'cast_model.freezed.dart';
part 'cast_model.g.dart';

@freezed
class CastResponse with _$CastResponse {
  factory CastResponse({
    int? id,
    String? name,
    String? image,
    String? role,
  }) = _CastResponse;

  factory CastResponse.fromJson(Map<String, dynamic> json) => _$CastResponseFromJson(json);
}
