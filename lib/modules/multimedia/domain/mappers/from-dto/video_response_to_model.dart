import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

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
    bannerImage: response.bannerImage,
    duration: convertMinsToHoursAndMinutes(response.durationMins),
    collectionName: response.collectionName,
    categories: response.categories,
  );
}
