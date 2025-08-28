import 'package:freezed_annotation/freezed_annotation.dart';

part 'episode_model.freezed.dart';
part 'episode_model.g.dart';

@freezed
class EpisodeResponse with _$EpisodeResponse {
  factory EpisodeResponse({
    int? episodeId,
    int? episodeNumber,
    @JsonKey(name: "title") String? coverImage,
    String? description,
    int? durationMins,
    String? videoFile,
  }) = _EpisodeResponse;

  factory EpisodeResponse.fromJson(Map<String, dynamic> json) => _$EpisodeResponseFromJson(json);
}
