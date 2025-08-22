import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_response.freezed.dart';
part 'channel_response.g.dart';

@freezed
class ChannelResponse with _$ChannelResponse {
  factory ChannelResponse({
    required String name,
    required Uri url,
  }) = _ChannelResponse;


  factory ChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$ChannelResponseFromJson(json);
}
