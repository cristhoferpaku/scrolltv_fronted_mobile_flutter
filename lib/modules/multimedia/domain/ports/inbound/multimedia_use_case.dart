import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';

abstract class MultimediaUseCase {
  Future<ApiResponse<GetHomeSectionModel>> getHomeSection(int sectionId);
  Future<ApiResponse<VideoContentModel>> getVideoContentById(int videoId);
  Future<ApiResponse<List<VideoModel>>> getVideosByCollectionId(int collectionId);
  Future<ApiResponse<List<VideoModel>>> getVideosBySearch(String search);
  Future<ApiResponse<List<EpisodeModel>>> getEpisodesBySeasonId(int seasonId);
  Future<ApiResponse<List<CollectionModel>>> getCollectionsByVideoId(int videoId);
}
