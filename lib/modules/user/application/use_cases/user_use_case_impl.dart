import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/inbound/user_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/outbound/user_repository_port.dart';

class UserUseCaseImpl implements UserUseCase {
  final UserRepositoryPort _userRepositoryPort;
  UserUseCaseImpl(this._userRepositoryPort);
  @override
  Future<ApiResponse<UserModel>> getAll() async {
    return await _userRepositoryPort.getAll();
  }

  @override
  Future<UserModel> getById(int id) async {
    return await _userRepositoryPort.getById(id);
  }

  @override
  Future<UserModel> create(UserModel user) async {
    return await _userRepositoryPort.create(user);
  }

  @override
  Future<UserModel> update(int id, UserModel user) async {
    return await _userRepositoryPort.update(id, user);
  }

  @override
  Future<UserModel> delete(int id) async {
    return await _userRepositoryPort.delete(id);
  }
}
