import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/auth_user_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-dto/auth_user_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-entity/login_to_login_request.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';

class AuthApiRepository implements AuthRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  final baseApiUrl = Env.baseApiUrl;

  @override
  Future<ApiResponse<AuthUserModel>> login(LoginModel login) async {
    try {
      final httpService = await dio;

      final loginRequest = loginToLoginRequest(login);

      final response = await httpService.request(
          url: "$baseApiUrl/auth/login",
          method: Method.post,
          data: loginRequest);

      if (response.data != null) {
        final apiResponse = ApiResponse<AuthUserModel>.fromJson(
          response.data,
          (json) => authUserResponseToModel(
              AuthUserResponse.fromJson(json as Map<String, dynamic>)),
        );

        return apiResponse;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
