import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

abstract class TvPlayerUseCase {
  Future<ApiResponse<List<ChannelModel>>> getChannels();
  // List<ChannelCategoryModel> getCategories(List<ChannelModel> channels);
  Future<ApiResponse<List<ChannelModel>>> getChannelsByCategory(ChannelCategoryModel category);
  Future<ApiResponse<List<ChannelCategoryModel>>> getCategories();
}
