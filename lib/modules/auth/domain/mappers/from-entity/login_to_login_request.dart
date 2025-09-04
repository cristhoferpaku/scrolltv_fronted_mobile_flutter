import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/request/login_request.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';

LoginRequest loginToLoginRequest(LoginModel login) {
  return LoginRequest(
    username: login.username,
    password: login.password,
    id_device: login.deviceId,
    platform: login.platformId,
  );
}
