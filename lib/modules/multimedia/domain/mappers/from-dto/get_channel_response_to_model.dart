import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/channel_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/channel_model.dart';

ChannelModel getChannelResponseToModel(ChannelResponse channelResponse) {
  return ChannelModel(
    name: channelResponse.name,
    url: channelResponse.url,
  );
}

List<ChannelModel> getChannelsResponseToModel(List<ChannelResponse> channels) {
  return channels.map((e) => getChannelResponseToModel(e)).toList();
}