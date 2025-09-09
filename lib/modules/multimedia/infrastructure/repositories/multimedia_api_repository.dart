import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/get_home_section_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_content_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/video_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/get_home_section_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/video_content_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/video_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/outbound/multimedia_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

class MultimediaApiRepository implements MultimediaRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  final baseApiUrl = Env.baseApiUrl;

  @override
  Future<ApiResponse<GetHomeSectionModel>> getHomeSection(int sectionId) async {
    try {
      final httpService = await dio;

      final response = await httpService.request(
        url: "$baseApiUrl/get-home-data?sectionId=$sectionId",
        method: Method.get,
      );

      LoggerManager.log.i(response.data);
      if (response.data != null) {
        final apiResponse = ApiResponse<GetHomeSectionModel>.fromJson(
          response.data,
          (json) => getHomeSectionResponseToModel(GetHomeSectionResponse.fromJson(json as Map<String, dynamic>)),
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
      throw Exception(e.toString());
    }
  }

  @override
  Future<ApiResponse<VideoContentModel>> getVideoContentById(int videoId) async {
    final httpService = await dio;

    final response = await httpService.request(url: "$baseApiUrl/get-content-data-detail/$videoId", method: Method.get);

    if (response.data["data"] != null) {
      final videoResponse = VideoContentResponse.fromJson(response.data["data"]);
      final video = videoContentResponseToModel(videoResponse);
      return ApiResponseData<VideoContentModel>(success: true, data: video, timestamp: DateTime.now().toIso8601String(), path: response.requestOptions.path);
    } else {
      throw Exception("Something wen't wrong");
    }
  }

  @override
  Future<ApiResponse<List<VideoModel>>> getVideosByCollectionId(int collectionId) async {
    final httpService = await dio;

    try {
      final response = await httpService.request(url: "$baseApiUrl/get-collection-content/$collectionId", method: Method.get);

      if (response.data["data"] != null) {
        final videoResponse = VideoResponse.fromJsonList(response.data["data"]);
        final video = videoResponseToModelList(videoResponse);
        return ApiResponseData<List<VideoModel>>(success: true, data: video, timestamp: DateTime.now().toIso8601String(), path: response.requestOptions.path);
      } else {
        throw Exception("Something wen't wrong");
      }
    } catch (e) {
      throw Exception("Something wen't wrong");
    }
  }

  @override
  Future<ApiResponse<List<VideoModel>>> getVideosBySearch(String search) async {
    final httpService = await dio;

    try {
      final response = await httpService.request(url: "$baseApiUrl/get-search-content/?search=$search", method: Method.get);

      if (response.data["data"] != null) {
        final videoResponse = VideoResponse.fromJsonList(response.data["data"]);
        final video = videoResponseToModelList(videoResponse);
        return ApiResponseData<List<VideoModel>>(success: true, data: video, timestamp: DateTime.now().toIso8601String(), path: response.requestOptions.path);
      } else {
        throw Exception("Something wen't wrong");
      }
    } catch (e) {
      throw Exception("Something wen't wrong");
    }
  }
}
