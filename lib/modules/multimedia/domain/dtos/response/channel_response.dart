import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_response.freezed.dart';
part 'channel_response.g.dart';

@freezed
class ChannelResponse with _$ChannelResponse {
  factory ChannelResponse({
    required String name,
    required String url,
    required List<String> category,
    required String logo,
  }) = _ChannelResponse;

  factory ChannelResponse.fromJson(Map<String, dynamic> json) => _$ChannelResponseFromJson(json);
}
