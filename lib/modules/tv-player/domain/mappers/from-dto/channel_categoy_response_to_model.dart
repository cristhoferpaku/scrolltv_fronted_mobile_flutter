import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/dtos/response/channel_category_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';

ChannelCategoryModel channelCategoryResponseToModel(ChannelCategoryResponse channelCategoryResponse) {
  return ChannelCategoryModel(
    name: channelCategoryResponse.name,
    url: channelCategoryResponse.url,
    channels: [],
  );
}

List<ChannelCategoryModel> channelCategoryResponseToModelList(List<ChannelCategoryResponse> channelCategoryResponse) {
  return channelCategoryResponse.map((channelCategoryResponse) => channelCategoryResponseToModel(channelCategoryResponse)).toList();
}
