import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/collection_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/get_home_section_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';

GetHomeSectionModel getHomeSectionResponseToModel(
    GetHomeSectionResponse response) {
  return GetHomeSectionModel(
    banner: response.recentContent?.isNotEmpty ?? false
        ? videoResponseToModel(response.recentContent!.first)
        : null,
    top10: response.top10?.map((e) => videoResponseToModel(e)).toList(),
    recentContent:
        response.recentContent?.map((e) => videoResponseToModel(e)).toList(),
    collectionsContent: response.collectionsContent
        ?.map((e) => collectionResponseToModel(e))
        .toList(),
  );
}

CollectionModel collectionResponseToModel(CollectionResponse response) {
  return CollectionModel(
    collectionId: response.collectionId,
    collectionName: response.collectionName,
    content: response.content,
  );
}

VideoModel videoResponseToModel(VideoResponse response) {
  return VideoModel(
    id: response.id,
    title: response.title,
    description: response.description,
    coverImage: response.coverImage,
    type: response.type,
    durationMins: response.durationMins,
    videoUrl: response.videoUrl,
    sectionId: response.sectionId,
    countryId: response.countryId,
    collectionId: response.collectionId,
    createdAt: response.createdAt,
    updatedAt: response.updatedAt,
    topNumber: response.topNumber,
  );
}
