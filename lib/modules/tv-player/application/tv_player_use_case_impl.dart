import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/inbound/tv_player_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/outbound/tv_player_repository_port.dart';

class TvPlayerUseCaseImpl implements TvPlayerUseCase {
  final TvPlayerRepositoryPort tvPlayerRepositoryPort;

  TvPlayerUseCaseImpl(this.tvPlayerRepositoryPort);

  @override
  Future<ApiResponse<List<ChannelModel>>> getChannels() {
    return tvPlayerRepositoryPort.getChannels();
  }

  @override
  List<ChannelCategoryModel> getCategories(List<ChannelModel> channels) {
    // Extraer todas las categorías únicas en un Set
    final Set<String> categorySet = channels.map((c) => c.category.first).toSet();

    final List<ChannelCategoryModel> categories = categorySet.map((cat) {
      final filteredChannels = channels.where((ch) => ch.category.first == cat).toList();
      return ChannelCategoryModel(name: cat, channels: filteredChannels);
    }).toList();

    categories.insert(0, ChannelCategoryModel(name: 'todos', channels: channels));

    return categories;
  }

  @override
  List<ChannelModel> getChannelsByCategory(List<ChannelModel> channels, String name) {
    if (name == "todos") return channels;
    print(channels);
    return channels.where((e) => e.category.contains(name)).toList();
  }
}
