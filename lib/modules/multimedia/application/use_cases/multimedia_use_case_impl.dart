import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/outbound/multimedia_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

class MultimediaUseCaseImpl implements MultimediaUseCase {
  final MultimediaRepositoryPort _multimediaRepositoryPort;

  MultimediaUseCaseImpl(this._multimediaRepositoryPort);

  @override
  Future<ApiResponse<GetHomeSectionModel>> getHomeSection(int sectionId) async {
    final response = await _multimediaRepositoryPort.getHomeSection(sectionId);
    return response;
  }

  @override
  Future<ApiResponse<VideoContentModel>> getVideoContentById(int videoId) async {
    final response = await _multimediaRepositoryPort.getVideoContentById(videoId);
    return response;
  }

  @override
  Future<ApiResponse<List<VideoModel>>> getVideosByCollectionId(int collectionId) async {
    final response = await _multimediaRepositoryPort.getVideosByCollectionId(collectionId);
    return response;
  }

  @override
  Future<ApiResponse<List<VideoModel>>> getVideosBySearch(String search) async {
    final response = await _multimediaRepositoryPort.getVideosBySearch(search);
    return response;
  }

  @override
  Future<ApiResponse<List<EpisodeModel>>> getEpisodesBySeasonId(int seasonId) async {
    final response = await _multimediaRepositoryPort.getEpisodesBySeasonId(seasonId);
    LoggerManager.log.i(response);
    return response;
  }

  @override
  Future<ApiResponse<List<CollectionModel>>> getCollectionsByVideoId(int videoId) async {
    final response = await _multimediaRepositoryPort.getCollectionsByVideoId(videoId);
    return response;
  }
}
