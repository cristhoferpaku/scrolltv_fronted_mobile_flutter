import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  factory VideoModel({
    int? id,
    String? title,
    String? description,
    String? coverImage,
    String? type,
    int? durationMins,
    String? videoUrl,
    int? sectionId,
    int? countryId,
    int? collectionId,
    String? createdAt,
    String? updatedAt,
    int? topNumber,
    String? collectionName,
    String? categories,
    String? year,
    String? duration,
    String? bannerImage,
    VideoModel? contentInfo,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);
}
