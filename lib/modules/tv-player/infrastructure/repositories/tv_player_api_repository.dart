import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/domain/entities/dtos/response/api_response.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/outbound/tv_player_repository_port.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/constants/channels_data.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class TvPlayerApiRepository implements TvPlayerRepositoryPort {
  final dio = instance.getAsync<HttpDioService>();
  final baseApiUrl = Env.baseApiUrl;
  @override
  Future<ApiResponse<List<ChannelModel>>> getChannels() async {
    try {
      return ApiResponse<List<ChannelModel>>(data: channelsData, success: true, timestamp: DateTime.now().toString(), path: 'fetch-channels');
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

        return ApiResponse<List<ChannelModel>>(data: channelsData, success: true, timestamp: DateTime.now().toString(), path: 'fetch-channels');
      } else {
        throw Exception('No se pudo descargar la lista M3U: ${response.statusCode}');
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
