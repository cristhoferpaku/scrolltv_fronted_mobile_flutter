import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';

CastModel castResponseToModel(CastResponse response) {
  return CastModel(
    id: response.id,
    name: response.name,
    image: response.image,
  );
}
