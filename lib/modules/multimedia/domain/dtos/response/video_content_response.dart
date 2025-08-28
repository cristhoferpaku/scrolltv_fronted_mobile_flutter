import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/season_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_response.dart';

part 'video_content_response.freezed.dart';
part 'video_content_response.g.dart';

@freezed
class VideoContentResponse with _$VideoContentResponse {
  factory VideoContentResponse({
    @JsonKey(name: "contentInfo") VideoResponse? video,
    @JsonKey(name: "seasonsData") List<SeasonResponse>? seasons,
    @JsonKey(name: "cast") List<CastResponse>? casts,
  }) = _VideoContentResponse;

  factory VideoContentResponse.fromJson(Map<String, dynamic> json) => _$VideoContentResponseFromJson(json);
}
