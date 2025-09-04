import 'package:freezed_annotation/freezed_annotation.dart';

part 'episode_model.freezed.dart';
part 'episode_model.g.dart';

@freezed
class EpisodeModel with _$EpisodeModel {
  factory EpisodeModel({
    int? episodeId,
    int? episodeNumber,
    String? coverImage,
    String? description,
    int? durationMins,
    String? videoUrl,
  }) = _EpisodeModel;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => _$EpisodeModelFromJson(json);
}
