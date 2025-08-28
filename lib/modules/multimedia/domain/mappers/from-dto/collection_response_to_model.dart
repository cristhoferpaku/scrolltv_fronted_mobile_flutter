import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/collection_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';

CollectionModel collectionResponseToModel(CollectionResponse response) {
  return CollectionModel(
    collectionId: response.collectionId,
    collectionName: response.collectionName,
    content: response.content,
  );
}
