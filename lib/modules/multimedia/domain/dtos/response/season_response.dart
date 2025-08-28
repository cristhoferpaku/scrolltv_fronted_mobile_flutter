import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/episode_model.dart';

part 'season_response.freezed.dart';
part 'season_response.g.dart';

@freezed
class SeasonResponse with _$SeasonResponse {
  factory SeasonResponse({
    int? seasonId,
    int? seasonNumber,
    String? coverImage,
    String? description,
    List<EpisodeResponse>? episodes,
  }) = _SeasonResponse;

  factory SeasonResponse.fromJson(Map<String, dynamic> json) => _$SeasonResponseFromJson(json);
}
