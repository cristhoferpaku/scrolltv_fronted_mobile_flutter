import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/dto/generic/exception/exception_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/env/env.dart';
//import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';
import 'package:path_provider/path_provider.dart';

enum Method { post, get, put, delete, patch }

var baseApiUrl = Env.baseApiUrl;

class HttpDioService {
  Dio? _dio;
  Directory? cachedirname;
  var userRepository = instance<UserRepository>();

  static Map<String, String> header() => {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
      };

  Future<HttpDioService> init() async {
    cachedirname = await getTemporaryDirectory();
    var cacheStore = HiveCacheStore(cachedirname?.path,
        hiveBoxName: '${Env.projectName}-hive');

    final optionsCache = CacheOptions(
        store: cacheStore,
        policy: CachePolicy.forceCache,
        maxStale: const Duration(minutes: 1),
        priority: CachePriority.high,
        hitCacheOnErrorExcept: [401, 404],
        keyBuilder: (request) {
          return request.uri.toString();
        },
        allowPostMethod: false);

    _dio = Dio(BaseOptions(
      baseUrl: baseApiUrl,
      headers: header(),
      validateStatus: (status) {
        // Acepta cualquier status < 500 para que llegue al try/catch
        return status != null && status < 500;
      },
    ))
      ..interceptors.addAll([
        DioCacheInterceptor(options: optionsCache),
        InterceptorsWrapper(
          onRequest: (requestOptions, handler) async {
            requestOptions.followRedirects = false;

            var currentToken = await getCurrentTokenUser();
            if (currentToken.isNotEmpty) {
              requestOptions.headers['Authorization'] = 'Bearer $currentToken';
            }

            return handler.next(requestOptions);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (error, handler) async {
            final refreshTokenUser = await userRepository.getTokenRefresh();

            if (refreshTokenUser.isNotEmpty &&
                (error.response?.statusCode == 401 ||
                    error.response?.statusCode == 403)) {
              await refreshToken();

              final cloneReq = await _dio?.request(error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters);

              var newToken = await getCurrentTokenUser();

              if (newToken.isNotEmpty) {
                cloneReq?.headers.add('Content-Type', 'application/json');
                cloneReq?.headers.add('Authorization', 'Bearer $newToken');
              }

              handler.resolve(cloneReq!);
            }

            return handler.next(error);
          },
        ),
      ]);
    //initInterceptors();
    return this;
  }

  Future<dynamic> request({
    required String url,
    required Method method,
    Map<String, dynamic>? params,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? requestOptions,
    //bool? isAutorizated ,
  }) async {
    Response response;

    try {
      if (method == Method.post) {
        response = await _dio!.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
        );
      } else if (method == Method.delete) {
        response = await _dio!.delete(url);
      } else if (method == Method.patch) {
        response = await _dio!.patch(url);
      } else if (method == Method.put) {
        response = await _dio!.put(url, data: data, options: requestOptions);
      } else {
        response = await _dio!.get(url, queryParameters: params);
      }

      if (response.statusCode == 200 || response.statusCode == 304) {
        return response;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 500) {
        throw Exception('Server Error');
      } else if (response.statusCode == 400) {
        throw Exception('Wrong Pass');
      } else {
        throw Exception("Something does wen't wrong");
      }
    } on SocketException catch (e) {
      throw Exception('Not Internet Connection: $e');
    } on FormatException catch (e) {
      throw Exception('Bad response format: $e');
    } on DioException catch (e) {
      if (e.response!.statusCode == 500) {
        throw ExceptionApp(500, e.response!.data['message']);
      } else {
        throw Exception('Dio Error: ${e.message}');
      }
    } catch (e) {
      throw Exception("Something wen't wrong");
    }
  }

  Future<String> getCurrentTokenUser() async {
    return await userRepository.getToken();
  }

  Future<String> getCurrentRefreshToken() async {
    return await userRepository.getTokenRefresh();
  }

  Future<void> refreshToken() async {}
}
