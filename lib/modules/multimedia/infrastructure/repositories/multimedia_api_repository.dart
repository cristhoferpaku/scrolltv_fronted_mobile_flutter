import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/get_home_section_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/mappers/from-dto/get_home_section_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/outbound/multimedia_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/data/default_data.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/m3u_parser.dart';

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
          (json) => getHomeSectionResponseToModel(
              GetHomeSectionResponse.fromJson(json as Map<String, dynamic>)),
        );

        return apiResponse;
      } else {
        // Verificar si response.data es un Map y contiene 'message'
        String errorMessage = 'Error desconocido';
        if (response.data is Map<String, dynamic> &&
            response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Error de conectividad/red
      throw Exception('Sin conexión a internet: ${e.message}');
    } on DioException catch (e) {
      // Errores específicos de Dio (timeouts, HTTP errors, etc.)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Tiempo de espera agotado. Verifica que el servidor esté ejecutándose en $baseApiUrl');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'No se puede conectar al servidor en $baseApiUrl. Verifica que el servidor esté ejecutándose.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Datos de login incorrectos');
      } else if (e.response?.statusCode == 500) {
        // Verificar si hay mensaje específico del servidor
        String serverMessage = 'Error interno del servidor';
        if (e.response?.data is Map<String, dynamic> &&
            e.response?.data['message'] != null) {
          serverMessage =
              e.response?.data['message'].toString() ?? serverMessage;
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

  /// Método para obtener canales desde una playlist M3U
  @override
  Future<ApiResponse<List<ChannelModel>>> fetchChannels() async {
    try {
      String playlistUrl = 'https://noalatino.org:443/playlist/demorestream62/demo62/m3u?output=hls';
      final playlistUri = Uri.parse(playlistUrl);
      final httpService = await dio;

      final response = await httpService.request(
        url: playlistUri.toString(),
        method: Method.get,
        requestOptions: Options(
          headers: {
            // Algunos proveedores requieren User-Agent
            'User-Agent': 'VLC/3.0 libVLC/3.0',
            // Agrega auth extra si el proveedor lo pide en headers (no es tu caso).
          },
        ),
      );

      LoggerManager.log.i('Playlist response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Si la respuesta es String, la usamos directamente
        String playlistContent;
        if (response.data is String) {
          playlistContent = response.data as String;
        } else {
          // Si no es String, intentamos convertirla
          playlistContent = response.data.toString();
        }
        
        return  ApiResponse<List<ChannelModel>>(data: parseM3u(playlistContent), success: true, timestamp: DateTime.now().toString(), path: 'fetch-channels');

      } else {
        throw Exception('No se pudo descargar la lista M3U: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Error de conectividad/red
      throw Exception('Sin conexión a internet: ${e.message}');
    } on DioException catch (e) {
      // Errores específicos de Dio (timeouts, HTTP errors, etc.)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Tiempo de espera agotado. Verifica que el servidor de playlist esté disponible en la url');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'No se puede conectar al servidor de playlist en la url. Verifica la URL.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Acceso no autorizado a la playlist');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Playlist no encontrada en la URL proporcionada');
      } else if (e.response?.statusCode == 500) {
        // Verificar si hay mensaje específico del servidor
        String serverMessage = 'Error interno del servidor de playlist';
        if (e.response?.data is Map<String, dynamic> &&
            e.response?.data['message'] != null) {
          serverMessage =
              e.response?.data['message'].toString() ?? serverMessage;
        }
        throw ExceptionApp(500, serverMessage);
      } else {
        throw Exception('Error de red al descargar playlist: ${e.message ?? 'Error desconocido'}');
      }
    } on FormatException catch (e) {
      // Error de formato en la respuesta
      throw Exception('Formato de playlist inválido: ${e.message}');
    } on ExceptionApp {
      // Re-lanzar ExceptionApp sin modificar
      rethrow;
    } catch (e) {
      // Cualquier otro error no manejado
      LoggerManager.log.e('Error en fetchChannels: ${e.toString()}');
      throw Exception('Error al procesar la playlist: ${e.toString()}');
    }
  }
}
