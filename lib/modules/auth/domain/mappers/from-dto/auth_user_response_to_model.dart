import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/auth_user_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-dto/token_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/mappers/from-dto/user_response_to_model.dart';

AuthUserModel authUserResponseToModel(AuthUserResponse authUserResponse) {
  return AuthUserModel(
    user: authUserResponse.user != null
        ? userResponseToModel(authUserResponse.user!)
        : null,
    tokens: authUserResponse.tokens != null
        ? tokenResponseToModel(authUserResponse.tokens!)
        : null,
  );
}
