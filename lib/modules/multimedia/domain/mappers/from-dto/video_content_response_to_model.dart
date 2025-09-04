import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_content_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/cast_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/season_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/video_response_to_model.dart';

VideoContentModel videoContentResponseToModel(VideoContentResponse response) {
  return VideoContentModel(
    video: response.video != null ? videoResponseToModel(response.video!) : null,
    seasons: response.seasons?.map((season) => seasonResponseToModel(season)).toList(),
    casts: response.casts?.map((cast) => castResponseToModel(cast)).toList(),
  );
}

List<VideoContentModel> videoContentResponseToModelList(List<VideoContentResponse> response) {
  return response.map((response) => videoContentResponseToModel(response)).toList();
}
