import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';

abstract class MultimediaUseCase {
  Future<ApiResponse<GetHomeSectionModel>> getHomeSection(int sectionId);
  Future<ApiResponse<List<ChannelModel>>> fetchChannels();
  Future<ApiResponse<VideoContentModel>> getVideoContentById(int videoId);
}
