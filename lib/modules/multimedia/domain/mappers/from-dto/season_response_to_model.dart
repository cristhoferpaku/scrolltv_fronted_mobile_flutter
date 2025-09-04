import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/season_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/season_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/episode_response_to_model.dart';

SeasonModel seasonResponseToModel(SeasonResponse response) {
  return SeasonModel(
    seasonId: response.seasonId,
    seasonNumber: response.seasonNumber,
    coverImage: response.coverImage,
    description: response.description,
    episodes: response.episodes?.map((episode) => episodeResponseToModel(episode)).toList(),
  );
}
