import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/inbound/tv_player_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/outbound/tv_player_repository_port.dart';

class TvPlayerUseCaseImpl implements TvPlayerUseCase {
  final TvPlayerRepositoryPort tvPlayerRepositoryPort;

  TvPlayerUseCaseImpl(this.tvPlayerRepositoryPort);

  @override
  Future<ApiResponse<List<ChannelModel>>> getChannels() async {
    final channels = await tvPlayerRepositoryPort.getChannels();
    return channels;
  }

  @override
  Future<ApiResponse<List<ChannelCategoryModel>>> getCategories() {
    return tvPlayerRepositoryPort.getCategories();
  }

  @override
  Future<ApiResponse<List<ChannelModel>>> getChannelsByCategory(ChannelCategoryModel category) {
    return tvPlayerRepositoryPort.getChannelsByCategory(category);
  }
}
