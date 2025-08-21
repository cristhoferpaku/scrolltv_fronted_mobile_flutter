import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/collection_response.dart';

part 'get_home_section_response.freezed.dart';
part 'get_home_section_response.g.dart';

@freezed
class GetHomeSectionResponse with _$GetHomeSectionResponse {
  factory GetHomeSectionResponse({
    @JsonKey(name: 'top10') List<VideoResponse>? top10,
    @JsonKey(name: 'recentContent') List<VideoResponse>? recentContent,
    @JsonKey(name: 'collectionsContent')
    List<CollectionResponse>? collectionsContent,
  }) = _GetHomeSectionResponse;

  factory GetHomeSectionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetHomeSectionResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
