import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';

part 'get_home_section_model.freezed.dart';
part 'get_home_section_model.g.dart';

@freezed
class GetHomeSectionModel with _$GetHomeSectionModel {
  factory GetHomeSectionModel({
    List<VideoModel>? top10,
    List<VideoModel>? recentContent,
    List<CollectionModel>? collectionsContent,
  }) = _GetHomeSectionModel;

  factory GetHomeSectionModel.fromJson(Map<String, dynamic> json) =>
      _$GetHomeSectionModelFromJson(json);
}
