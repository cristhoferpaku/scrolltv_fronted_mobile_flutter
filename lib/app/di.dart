
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/config_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  initInfoVersion();
  initDioService();
  initRepositoryModule();
}

Future<void> listAppModule() async {
  //OTRAS PANTALLAS
  //initCompanyService();
}
void initContext(BuildContext context) {
  if (!GetIt.I.isRegistered<BuildContext>()) {
    instance.registerSingleton<BuildContext>(context);
  }
}

Future<void> waitingForModulesAsync() async {
  await GetIt.I.isReady<PackageInfo>();
}
void initInfoVersion() {
  if (!GetIt.I.isRegistered<PackageInfo>()) {
    instance.registerSingletonAsync<PackageInfo>(() async {
      var packageInfo = await PackageInfo.fromPlatform();
      return packageInfo;
    });
  }
}


// SERVICES
void initDioService() {
  if (!GetIt.I.isRegistered<HttpDioService>()) {
    instance.registerFactoryAsync<HttpDioService>(() async {
      var dio = HttpDioService();
      await dio.init();
      return dio;
    });
  }
}



void initRepositoryModule() {
  if (!GetIt.I.isRegistered<ConfigRepositoryImpl>()) {
    instance
        .registerFactory<ConfigRepositoryImpl>(() => ConfigRepositoryImpl());
  }
}