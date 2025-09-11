import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_category_response.freezed.dart';
part 'channel_category_response.g.dart';

@freezed
class ChannelCategoryResponse with _$ChannelCategoryResponse {
  factory ChannelCategoryResponse({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'url') required String url,
  }) = _ChannelCategoryResponse;

  factory ChannelCategoryResponse.fromJson(Map<String, dynamic> json) => _$ChannelCategoryResponseFromJson(json);

  static List<ChannelCategoryResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ChannelCategoryResponse.fromJson(json)).toList();
  }
}
