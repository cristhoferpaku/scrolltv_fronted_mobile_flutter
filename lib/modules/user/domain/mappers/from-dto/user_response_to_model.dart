import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/dtos/response/user_response.dart';

UserModel userResponseToModel(UserResponse userResponse) {
  return UserModel(
    id: userResponse.id,
    username: userResponse.username,
    platformId: userResponse.platformId,
    platformName: userResponse.platformName,
    packageUserId: userResponse.packageUserId,
    packageUserName: userResponse.packageUserName,
    status: userResponse.status,
    serviceStarted: userResponse.serviceStarted,
    startDate: userResponse.startDate,
    expirationDate: userResponse.expirationDate,
    canChangePackage: userResponse.canChangePackage,
    createdAt: userResponse.createdAt,
    updatedAt: userResponse.updatedAt,
  );
}
