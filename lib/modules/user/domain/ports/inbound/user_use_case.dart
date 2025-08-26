import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';

abstract class UserUseCase {
  Future<ApiResponse<UserModel>> getAll();
  Future<ApiResponse<UserModel>> getById(int id);
  Future<UserModel> create(UserModel user);
  Future<UserModel> update(int id, UserModel user);
  Future<UserModel> delete(int id);
}
