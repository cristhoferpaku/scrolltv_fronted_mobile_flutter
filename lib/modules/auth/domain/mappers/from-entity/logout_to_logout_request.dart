import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/request/logout_request.dart';

LogoutRequest logoutToLogoutRequest(String deviceId) {
  return LogoutRequest(id_device: deviceId);
}
