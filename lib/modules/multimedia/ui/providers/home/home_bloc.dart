import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/domain/ports/inbound/auth_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(_Initial()) {
    final UserRepository userRepository = instance<UserRepository>();
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    final AuthUseCase authUseCase = instance<AuthUseCase>();
    GetHomeSectionModel? moviesSection;
    GetHomeSectionModel? seriesSection;
    GetHomeSectionModel? animesSection;
    GetHomeSectionModel? dramasSection;
    GetHomeSectionModel? kidsSection;
    List<ChannelModel>? selectedChannel;
    String firstLetterUsername = "";
    on<HomeEvent>((event, emit) async {});

    on<_HomeEventStarted>((event, emit) async {
      firstLetterUsername = await userRepository.getUserName().then((value) => value.substring(0, 1).toUpperCase());

      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingChannels,
          firstLetterUsername: firstLetterUsername));
    });

    on<_HomeEventLoadSectionLive>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingChannels,
          firstLetterUsername: firstLetterUsername));
      try {
        // final channelsResponse = await multimediaUseCase.fetchChannels();
        // selectedChannel = channelsResponse.data;

        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedChannels,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
    on<_HomeEventLoadSectionMovies>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingMovies,
          firstLetterUsername: firstLetterUsername));
      try {
        if (moviesSection == null) {
          final moviesResult = await multimediaUseCase.getHomeSection(1);
          moviesSection = moviesResult.data;
        }
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedMovies,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
    on<_HomeEventLoadSectionSeries>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingSeries,
          firstLetterUsername: firstLetterUsername));
      try {
        if (seriesSection == null) {
          final seriesResult = await multimediaUseCase.getHomeSection(2);
          seriesSection = seriesResult.data;
        }
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedSeries,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
    on<_HomeEventLoadSectionAnimes>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingAnimes,
          firstLetterUsername: firstLetterUsername));
      try {
        if (animesSection == null) {
          final animesResult = await multimediaUseCase.getHomeSection(4);
          animesSection = animesResult.data;
        }
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedAnimes,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
    on<_HomeEventLoadSectionDramas>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingDramas,
          firstLetterUsername: firstLetterUsername));
      try {
        if (dramasSection == null) {
          final dramasResult = await multimediaUseCase.getHomeSection(5);
          dramasSection = dramasResult.data;
        }
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedDramas,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
    on<_HomeEventLoadSectionKids>((event, emit) async {
      emit(HomeState.loaded(
          channels: selectedChannel,
          movies: moviesSection,
          series: seriesSection,
          animes: animesSection,
          dramas: dramasSection,
          kids: kidsSection,
          status: HomeStateStatus.loadingKids,
          firstLetterUsername: firstLetterUsername));
      try {
        if (kidsSection == null) {
          final kidsResult = await multimediaUseCase.getHomeSection(3);
          kidsSection = kidsResult.data;
        }
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.loadedKids,
            firstLetterUsername: firstLetterUsername));
      } catch (e) {
        emit(HomeState.loaded(
            channels: selectedChannel,
            movies: moviesSection,
            series: seriesSection,
            animes: animesSection,
            dramas: dramasSection,
            kids: kidsSection,
            status: HomeStateStatus.error,
            firstLetterUsername: firstLetterUsername));
      }
    });
  }
}
