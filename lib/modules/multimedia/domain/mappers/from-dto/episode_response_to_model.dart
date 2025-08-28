import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';

EpisodeModel episodeResponseToModel(EpisodeResponse response) {
  return EpisodeModel(
    episodeId: response.episodeId,
    episodeNumber: response.episodeNumber,
    coverImage: response.coverImage,
    description: response.description,
    durationMins: response.durationMins,
    videoUrl: response.videoFile,
  );
}
