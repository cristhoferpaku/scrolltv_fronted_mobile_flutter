import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/season_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';

part 'video_content_model.freezed.dart';
part 'video_content_model.g.dart';

@freezed
class VideoContentModel with _$VideoContentModel {
  factory VideoContentModel({VideoModel? video, List<SeasonModel>? seasons, List<CastModel>? casts}) = _VideoContentModel;

  factory VideoContentModel.fromJson(Map<String, dynamic> json) => _$VideoContentModelFromJson(json);
}
