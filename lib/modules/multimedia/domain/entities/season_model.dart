import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';

part 'season_model.freezed.dart';
part 'season_model.g.dart';

@freezed
class SeasonModel with _$SeasonModel {
  factory SeasonModel({
    int? seasonId,
    int? seasonNumber,
    String? coverImage,
    String? description,
    List<EpisodeModel>? episodes,
    List<CastModel>? casts,
  }) = _SeasonModel;

  factory SeasonModel.fromJson(Map<String, dynamic> json) => _$SeasonModelFromJson(json);
}
