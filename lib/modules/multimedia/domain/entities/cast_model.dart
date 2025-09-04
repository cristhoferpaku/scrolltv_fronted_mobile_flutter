import 'package:freezed_annotation/freezed_annotation.dart';

part 'cast_model.freezed.dart';
part 'cast_model.g.dart';

@freezed
class CastModel with _$CastModel {
  factory CastModel({
    int? id,
    String? name,
    String? image,
    String? role,
  }) = _CastModel;

  factory CastModel.fromJson(Map<String, dynamic> json) => _$CastModelFromJson(json);
}
