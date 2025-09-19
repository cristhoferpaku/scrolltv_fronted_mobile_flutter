import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class AuthUseCaseImpl implements AuthUseCase {
  final UserRepository _userRepository = instance<UserRepository>();
  final AuthRepositoryPort _authRepositoryPort;
  AuthUseCaseImpl(this._authRepositoryPort);

  @override
  Future<ApiResponse<AuthUserModel>> login(LoginModel user) async {
    final response = await _authRepositoryPort.login(user);

    if (response.success == true && response.data.tokens?.accessToken != null) {
      final accessToken = response.data.tokens?.accessToken;
      if (accessToken != null) {
        await _userRepository.saveToken(accessToken);
        await _userRepository.saveTokenRefresh(response.data.tokens?.refreshToken ?? "");
        await _userRepository.saveUser("", response.data.user?.username ?? "", "");
        await _userRepository.saveUserId(response.data.user?.id?.toString() ?? "");
        final deviceId = await PlatformUtils().getDeviceId();
        await _userRepository.saveDeviceId(deviceId);
      }
    }
    return response;
  }

  @override
  Future<void> logout() async {
    final deviceId = await _userRepository.getDeviceId() ?? "";
    await _authRepositoryPort.logout(deviceId);
  }

  @override
  Future<ApiResponse<void>> validateServiceExpiration(String deviceId) async {
    return await _authRepositoryPort.validateServiceExpiration(deviceId);
  }
}
