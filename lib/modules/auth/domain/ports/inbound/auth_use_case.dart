import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';

abstract class AuthUseCase {
  Future<ApiResponse<AuthUserModel>> login(LoginModel user);
  Future<void> logout();
  Future<ApiResponse<void>> validateServiceExpiration(String deviceId);
}
