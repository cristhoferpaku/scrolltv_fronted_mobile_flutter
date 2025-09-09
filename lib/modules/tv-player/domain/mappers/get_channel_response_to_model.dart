import 'dart:math';

import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/channel_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

ChannelModel getChannelResponseToModel(ChannelResponse channelResponse) {
  return ChannelModel(
    id: generateId(),
    name: channelResponse.name,
    url: channelResponse.url,
    logo: channelResponse.logo,
    category: channelResponse.category,
  );
}

List<ChannelModel> getChannelsResponseToModel(List<ChannelResponse> channels) {
  return channels.map((e) => getChannelResponseToModel(e)).toList();
}

int generateId() {
  final now = DateTime.now().microsecondsSinceEpoch; // más resolución que millis
  final random = Random().nextInt(1 << 20); // 20 bits de random
  return now ^ random; // XOR para mezclar ambos
}
