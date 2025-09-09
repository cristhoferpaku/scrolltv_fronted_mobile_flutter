import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

abstract class TvPlayerRepositoryPort {
  Future<ApiResponse<List<ChannelModel>>> getChannels();
}
