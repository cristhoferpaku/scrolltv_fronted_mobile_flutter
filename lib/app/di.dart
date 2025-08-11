import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/config_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/application/use_cases/auth_use_case_impl.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/infrastructure/repositories/auth_api_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  initDioService();
  initUserRepository();
  initInfoVersion();
  initRepositoryModule();
  initAuthDependencies();
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

initAuthDependencies() {
  initAuthRepositoryPort();
  initAuthUseCase();
  initAuthModule();
}

initAuthModule() {
  if (!GetIt.I.isRegistered<LoginBloc>()) {
    instance.registerLazySingleton<LoginBloc>(() => LoginBloc());
  }
}

initAuthUseCase() {
  if (!GetIt.I.isRegistered<AuthUseCase>()) {
    instance.registerFactory<AuthUseCase>(
        () => AuthUseCaseImpl(instance<AuthRepositoryPort>()));
  }
}

initAuthRepositoryPort() {
  if (!GetIt.I.isRegistered<AuthRepositoryPort>()) {
    instance.registerFactory<AuthRepositoryPort>(() => AuthApiRepository());
  }
}

initUserRepository() {
  if (!GetIt.I.isRegistered<UserRepository>()) {
    instance.registerFactory<UserRepository>(() => UserRepositoryImpl());
  }
}
