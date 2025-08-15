import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';

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
        _userRepository.saveToken(accessToken);
      }
    }
    return response;
  }
}
