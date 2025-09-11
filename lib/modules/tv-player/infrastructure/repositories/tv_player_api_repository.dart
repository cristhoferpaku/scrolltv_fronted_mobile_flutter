import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/dtos/response/channel_category_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/mappers/from-dto/channel_categoy_response_to_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/outbound/tv_player_repository_port.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/m3u_parser.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class TvPlayerApiRepository implements TvPlayerRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  final baseApiUrl = Env.baseApiUrl;
  @override
  Future<ApiResponse<List<ChannelModel>>> getChannels() async {
    try {
      final httpService = await dio;

      final playlistUrls = [
        'https://scroll-tv-movie-home-cdn.b-cdn.net/channels/24siete_animados.m3u',
        'https://scroll-tv-movie-home-cdn.b-cdn.net/channels/Canada.m3u',
        'https://scroll-tv-movie-home-cdn.b-cdn.net/channels/Brasil.m3u',
      ];

      List<ChannelModel> allChannels = [];

      for (final url in playlistUrls) {
        final response = await httpService.request(
          url: url,
          method: Method.get,
          requestOptions: Options(
            headers: {
              'User-Agent': 'VLC/3.0 libVLC/3.0',
            },
          ),
        );

        if ((response.statusCode == 200 || response.statusCode == 304) && response.data != null) {
          final playlistContent = response.data.toString();
          allChannels.addAll(parseM3u(playlistContent));
        }
      }

      return ApiResponse<List<ChannelModel>>(
        data: allChannels,
        success: true,
        timestamp: DateTime.now().toString(),
        path: 'fetch-channels',
      );
    } on SocketException catch (e) {
      // Error de conectividad/red
      throw Exception('Sin conexión a internet: ${e.message}');
    } on DioException catch (e) {
      // Errores específicos de Dio (timeouts, HTTP errors, etc.)
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
        throw Exception('Tiempo de espera agotado. Verifica que el servidor de playlist esté disponible en la url');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se puede conectar al servidor de playlist en la url. Verifica la URL.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Acceso no autorizado a la playlist');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Playlist no encontrada en la URL proporcionada');
      } else if (e.response?.statusCode == 500) {
        // Verificar si hay mensaje específico del servidor
        String serverMessage = 'Error interno del servidor de playlist';
        if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
          serverMessage = e.response?.data['message'].toString() ?? serverMessage;
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

  @override
  Future<ApiResponse<List<ChannelCategoryModel>>> getCategories() async {
    final httpService = await dio;

    try {
      final response = await httpService.request(url: "$baseApiUrl/get-all-live-tv", method: Method.get);

      if (response.data["data"] != null) {
        final categoriesResponse = ChannelCategoryResponse.fromJsonList(response.data["data"]);
        final categories = channelCategoryResponseToModelList(categoriesResponse);
        return ApiResponse<List<ChannelCategoryModel>>(success: true, data: categories, timestamp: DateTime.now().toIso8601String(), path: response.requestOptions.path);
      } else {
        throw Exception("Something wen't wrong");
      }
    } catch (e) {
      throw Exception("Something wen't wrong");
    }
  }

  @override
  Future<ApiResponse<List<ChannelModel>>> getChannelsByCategory(ChannelCategoryModel category) async {
    try {
      final httpService = await dio;

      if (category.url == null) {
        throw Exception("Something wen't wrong");
      }

      final playlistUrl = category.url;

      final response = await httpService.request(
        url: playlistUrl ?? '',
        method: Method.get,
        requestOptions: Options(
          headers: {
            'User-Agent': 'VLC/3.0 libVLC/3.0',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 304) && response.data != null) {
        LoggerManager.log.i("Channels by category: ${response.data}");
        final playlistContent = response.data.toString();
        final channels = parseM3u(playlistContent);
        return ApiResponse<List<ChannelModel>>(success: true, data: channels, timestamp: DateTime.now().toIso8601String(), path: response.requestOptions.path);
      } else {
        throw Exception("Something wen't wrong");
      }
    } on SocketException catch (e) {
      // Error de conectividad/red
      throw Exception('Sin conexión a internet: ${e.message}');
    } on DioException catch (e) {
      // Errores específicos de Dio (timeouts, HTTP errors, etc.)
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
        throw Exception('Tiempo de espera agotado. Verifica que el servidor de playlist esté disponible en la url');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se puede conectar al servidor de playlist en la url. Verifica la URL.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Acceso no autorizado a la playlist');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Playlist no encontrada en la URL proporcionada');
      } else if (e.response?.statusCode == 500) {
        // Verificar si hay mensaje específico del servidor
        String serverMessage = 'Error interno del servidor de playlist';
        if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
          serverMessage = e.response?.data['message'].toString() ?? serverMessage;
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
