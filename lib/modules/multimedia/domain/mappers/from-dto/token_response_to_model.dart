import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/token_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/token_response.dart';

TokenModel tokenResponseToModel(TokenResponse tokenResponse) {
  return TokenModel(
    accessToken: tokenResponse.accessToken,
    refreshToken: tokenResponse.refreshToken,
    expiresIn: tokenResponse.expiresIn,
    refreshExpiresIn: tokenResponse.refreshExpiresIn,
    tokenType: tokenResponse.tokenType,
  );
}
