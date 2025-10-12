import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/dtos/response/auth_user_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/auth_user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/entities/login_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-dto/auth_user_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-entity/login_to_login_request.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/mappers/from-entity/logout_to_logout_request.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

class AuthApiRepository implements AuthRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  final baseApiUrl = Env.baseApiUrl;

  @override
  Future<ApiResponse<AuthUserModel>> login(LoginModel login) async {
    try {
      final httpService = await dio;
      final loginRequest = loginToLoginRequest(login);

      final response = await httpService.request(url: "$baseApiUrl/auth/client-login", method: Method.post, data: loginRequest);

      if (response.data != null) {
        final apiResponse = ApiResponse<AuthUserModel>.fromJson(
          response.data,
          (json) => authUserResponseToModel(AuthUserResponse.fromJson(json as Map<String, dynamic>)),
        );

        return apiResponse;
      } else {
        // Verificar si response.data es un Map y contiene 'message'
        String errorMessage = 'Error desconocido';
        if (response.data is Map<String, dynamic> && response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Error de conectividad/red
      throw Exception('Sin conexión a internet: ${e.message}');
    } on DioException catch (e) {
      // Errores específicos de Dio (timeouts, HTTP errors, etc.)
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
        throw Exception('Tiempo de espera agotado. Verifica que el servidor esté ejecutándose en $baseApiUrl');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se puede conectar al servidor en $baseApiUrl. Verifica que el servidor esté ejecutándose.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Datos de login incorrectos');
      } else if (e.response?.statusCode == 500) {
        // Verificar si hay mensaje específico del servidor
        String serverMessage = 'Error interno del servidor';
        if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
          serverMessage = e.response?.data['message'].toString() ?? serverMessage;
        }
        throw ExceptionApp(500, serverMessage);
      } else {
        throw Exception('Error de red: ${e.message ?? 'Error desconocido'}');
      }
    } on FormatException catch (e) {
      // Error de formato en la respuesta
      throw Exception('Formato de respuesta inválido: ${e.message}');
    } on ExceptionApp {
      // Re-lanzar ExceptionApp sin modificar

      rethrow;
    } catch (e) {
      // Cualquier otro error no manejado
      LoggerManager.log.e(e.toString());
      rethrow;
    }
  }

  @override
  Future<ApiResponse<void>> logout(String deviceId) async {
    final httpService = await dio;

    final logoutRequest = logoutToLogoutRequest(deviceId);
    try {
      final response = await httpService.request(url: "$baseApiUrl/logout-mobile", method: Method.post, data: logoutRequest);

      LoggerManager.log.e(response.data.toString());
      if (response.data != null) {
        ApiResponse<void> apiResponse = ApiResponse<void>.fromJson(response.data, (json) {});
        return apiResponse;
      } else {
        throw Exception("Something wen't wrong");
      }
    } catch (e) {
      LoggerManager.log.e(e.toString());
      rethrow;
    }
  }

  @override
  Future<ApiResponse<void>> validateServiceExpiration(String deviceId) async {
    final httpService = await dio;

    try {
      final response = await httpService.request(url: "$baseApiUrl/validate-service-expiration", method: Method.post, data: {"device_id": deviceId});

      LoggerManager.log.i(response.data.toString());

      if (response.data != null) {
        // if (response.data["data"] != null) {
        //   ExpirationResponse expirationResponse = ExpirationResponse.fromJson(response.data["data"]);
        //   if (expirationResponse.success == false) {
        //     throw Exception(expirationResponse.message);
        //   }

        return ApiResponse<void>.fromJson(response.data, (json) {});
      } else {
        throw Exception("Something wen't wrong");
      }
    } catch (e) {
      LoggerManager.log.e(e.toString());
      rethrow;
    }
  }
}
