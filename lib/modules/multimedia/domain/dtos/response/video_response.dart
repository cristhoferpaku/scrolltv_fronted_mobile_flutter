import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_response.freezed.dart';
part 'video_response.g.dart';

@freezed
class VideoResponse with _$VideoResponse {
  factory VideoResponse({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'coverImage') String? coverImage,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'durationMins') int? durationMins,
    @JsonKey(name: 'videoUrl') String? videoUrl,
    @JsonKey(name: 'sectionId') int? sectionId,
    @JsonKey(name: 'countryId') int? countryId,
    @JsonKey(name: 'collectionId') int? collectionId,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
    @JsonKey(name: 'topNumber') int? topNumber,
  }) = _VideoResponse;

  factory VideoResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
