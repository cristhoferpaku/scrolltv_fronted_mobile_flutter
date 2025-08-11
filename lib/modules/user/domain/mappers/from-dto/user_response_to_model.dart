import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/dtos/response/user_response.dart';

UserModel userResponseToModel(UserResponse userResponse) {
  return UserModel(
    id: userResponse.id ?? 0,
    name: userResponse.name ?? "",
  );
}
