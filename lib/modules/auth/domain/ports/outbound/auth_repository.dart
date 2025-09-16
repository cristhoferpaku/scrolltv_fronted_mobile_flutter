import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';

abstract class AuthRepositoryPort {
  Future<ApiResponse<AuthUserModel>> login(LoginModel login);
  Future<void> logout(String deviceId);
  Future<ApiResponse<void>> validateServiceExpiration(String deviceId);
}
