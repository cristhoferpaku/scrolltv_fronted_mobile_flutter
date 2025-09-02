import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/login_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';

LoginModel loginResponseToModel(LoginResponse loginResponse) {
  return LoginModel(
    username: loginResponse.username ?? "",
    password: loginResponse.password ?? "",
    deviceId: "",
    platformId: 0,
  );
}
