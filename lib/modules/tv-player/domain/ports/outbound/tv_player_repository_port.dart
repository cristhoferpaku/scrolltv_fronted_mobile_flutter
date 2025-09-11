import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

abstract class TvPlayerRepositoryPort {
  Future<ApiResponse<List<ChannelModel>>> getChannels();
  Future<ApiResponse<List<ChannelCategoryModel>>> getCategories();
  Future<ApiResponse<List<ChannelModel>>> getChannelsByCategory(ChannelCategoryModel category);
}
