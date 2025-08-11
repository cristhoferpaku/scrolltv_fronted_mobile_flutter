import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/dtos/response/user_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/mappers/from-dto/user-response-to-model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/outbound/user_repository_port.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';

class UserApiRepository implements UserRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  @override
  Future<ApiResponse<UserModel>> getAll() async {
    final httpService = await dio;

    final response = await httpService.request(url: "", method: Method.get);

    if (response.data != null) {
      final userResponse = UserResponse.fromJson(response.data);
      final user = userResponseToModel(userResponse);
      return ApiResponseData<UserModel>(
          success: true,
          data: user,
          timestamp: DateTime.now().toIso8601String(),
          path: response.requestOptions.path);
    } else {
      throw Exception("Something wen't wrong");
    }
  }

  @override
  Future<UserModel> getById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> create(UserModel user) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> update(int id, UserModel user) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> delete(int id) {
    throw UnimplementedError();
  }
}
