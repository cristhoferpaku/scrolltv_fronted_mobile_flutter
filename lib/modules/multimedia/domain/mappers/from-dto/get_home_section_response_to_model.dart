import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/get_home_section_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/collection_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/video_response_to_model.dart';

GetHomeSectionModel getHomeSectionResponseToModel(GetHomeSectionResponse response) {
  return GetHomeSectionModel(
    banner: response.recentContent?.isNotEmpty ?? false ? videoResponseToModel(response.recentContent!.first) : null,
    top10: response.top10?.map((e) => videoResponseToModel(e)).toList(),
    recentContent: response.recentContent?.map((e) => videoResponseToModel(e)).toList(),
    collectionsContent: response.collectionsContent?.map((e) => collectionResponseToModel(e)).toList(),
  );
}
