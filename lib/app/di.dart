import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/config_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/application/use_cases/auth_use_case_impl.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/outbound/auth_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/infrastructure/repositories/auth_api_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/application/use_cases/multimedia_use_case_impl.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/outbound/multimedia_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/infrastructure/repositories/multimedia_api_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/collection/collection_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/video_details/video_details_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/providers/profile/profile_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/application/use_cases/user_use_case_impl.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/inbound/user_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/ports/outbound/user_repository_port.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/infrastructure/repositories/user_api_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player/video_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player_guia/video_player_bloc.dart' as videoPlayerBlocGuia;
import 'package:scrolltv_frontend_mobile_flutter/services/app_api_service.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/bloc/custom_tab_bar_bloc.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  initDioService();
  initUserRepository();
  initInfoVersion();
  initRepositoryModule();
  initAuthDependencies();
  initHomeDependencies();
  initProfileDependencies();
  initVideoDetailsDependencies();
  initCollectionDependencies();
  initSearchDependencies();
  initVideoDependencies();
  initAuthDependencies();
}

initAuthDependencies() {
  initAuthRepositoryPort();
  initAuthUseCase();
  initAuthModule();
  initLoginModule();
}

initHomeDependencies() {
  initHomeBloc();
  initTabBarModule();
  initMultimediaDependencies();
}

initMultimediaDependencies() {
  initMultimediaRepositoryPort();
  initMultimediaUseCase();
}

initProfileDependencies() {
  initUserRepositoryPort();
  initUserUseCase();
  initProfileModule();
}

initVideoDetailsDependencies() {
  initVideoDetailsModule();
}

initCollectionDependencies() {
  initCollectionModule();
}

initSearchDependencies() {
  initSearchModule();
}

initVideoDependencies() {
  initVideoPlayerModule();
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

//BLOCS
initAuthModule() {
  if (!GetIt.I.isRegistered<AuthBloc>()) {
    instance.registerLazySingleton<AuthBloc>(() => AuthBloc());
  }
}

initLoginModule() {
  if (!GetIt.I.isRegistered<LoginBloc>()) {
    instance.registerLazySingleton<LoginBloc>(() => LoginBloc());
  }
}

initHomeBloc() {
  if (!GetIt.I.isRegistered<HomeBloc>()) {
    instance.registerLazySingleton<HomeBloc>(() => HomeBloc());
  }
}

initProfileModule() {
  if (!GetIt.I.isRegistered<ProfileBloc>()) {
    instance.registerLazySingleton<ProfileBloc>(() => ProfileBloc());
  }
}

initVideoDetailsModule() {
  if (!GetIt.I.isRegistered<VideoDetailsBloc>()) {
    instance.registerLazySingleton<VideoDetailsBloc>(() => VideoDetailsBloc());
  }
}

initCollectionModule() {
  if (!GetIt.I.isRegistered<CollectionBloc>()) {
    instance.registerLazySingleton<CollectionBloc>(() => CollectionBloc());
  }
}

initSearchModule() {
  if (!GetIt.I.isRegistered<SearchBloc>()) {
    instance.registerLazySingleton<SearchBloc>(() => SearchBloc());
  }
}

initVideoPlayerModule() {
  if (!GetIt.I.isRegistered<VideoPlayerBloc>()) {
    instance.registerLazySingleton<VideoPlayerBloc>(() => VideoPlayerBloc());
  }
}

initVideoPlayerGuiaModule() {
  if (!GetIt.I.isRegistered<videoPlayerBlocGuia.VideoPlayerBloc>()) {
    instance.registerLazySingleton<videoPlayerBlocGuia.VideoPlayerBloc>(() => videoPlayerBlocGuia.VideoPlayerBloc());
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
    instance.registerFactory<ConfigRepositoryImpl>(() => ConfigRepositoryImpl());
  }
}

initAuthUseCase() {
  if (!GetIt.I.isRegistered<AuthUseCase>()) {
    instance.registerFactory<AuthUseCase>(() => AuthUseCaseImpl(instance<AuthRepositoryPort>()));
  }
}

initAuthRepositoryPort() {
  if (!GetIt.I.isRegistered<AuthRepositoryPort>()) {
    instance.registerFactory<AuthRepositoryPort>(() => AuthApiRepository());
  }
}

initMultimediaUseCase() {
  if (!GetIt.I.isRegistered<MultimediaUseCaseImpl>()) {
    instance.registerFactory<MultimediaUseCase>(() => MultimediaUseCaseImpl(instance<MultimediaRepositoryPort>()));
  }
}

initMultimediaRepositoryPort() {
  if (!GetIt.I.isRegistered<MultimediaRepositoryPort>()) {
    instance.registerFactory<MultimediaRepositoryPort>(() => MultimediaApiRepository());
  }
}

initUserUseCase() {
  if (!GetIt.I.isRegistered<UserUseCase>()) {
    instance.registerFactory<UserUseCase>(() => UserUseCaseImpl(instance<UserRepositoryPort>()));
  }
}

initUserRepositoryPort() {
  if (!GetIt.I.isRegistered<UserRepositoryPort>()) {
    instance.registerFactory<UserRepositoryPort>(() => UserApiRepository());
  }
}

// widgets
initTabBarModule() {
  if (!GetIt.I.isRegistered<CustomTabBarBloc>()) {
    instance.registerLazySingleton<CustomTabBarBloc>(() => CustomTabBarBloc());
  }
}

//REPOSITORY
initUserRepository() {
  if (!GetIt.I.isRegistered<UserRepository>()) {
    instance.registerFactory<UserRepository>(() => UserRepositoryImpl());
  }
}
