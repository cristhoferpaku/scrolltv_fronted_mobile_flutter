import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';

part 'collection_response.freezed.dart';
part 'collection_response.g.dart';

@freezed
class CollectionResponse with _$CollectionResponse {
  factory CollectionResponse({
    int? collectionId,
    String? collectionName,
    List<VideoModel>? content,
  }) = _CollectionResponse;

  factory CollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionResponseFromJson(json);
}
