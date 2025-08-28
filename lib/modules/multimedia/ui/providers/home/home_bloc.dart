import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/types/home_state_status.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(_Initial()) {
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    GetHomeSectionModel? moviesSection;
    GetHomeSectionModel? seriesSection;
    GetHomeSectionModel? animesSection;
    GetHomeSectionModel? dramasSection;
    GetHomeSectionModel? kidsSection;
    List<ChannelModel>? selectedChannel;

    on<_HomeEventStarted>((event, emit) async {});

    on<_HomeEventLoadSectionLive>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (selectedChannel == null) {
          final channelsResponse = await multimediaUseCase.fetchChannels();
          selectedChannel = channelsResponse.data;
        }

        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
    on<_HomeEventLoadSectionMovies>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (moviesSection == null) {
          final moviesResult = await multimediaUseCase.getHomeSection(1);
          moviesSection = moviesResult.data;
        }
        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
    on<_HomeEventLoadSectionSeries>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (seriesSection == null) {
          final seriesResult = await multimediaUseCase.getHomeSection(2);
          seriesSection = seriesResult.data;
        }
        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
    on<_HomeEventLoadSectionAnimes>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (animesSection == null) {
          final animesResult = await multimediaUseCase.getHomeSection(4);
          animesSection = animesResult.data;
        }
        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
    on<_HomeEventLoadSectionDramas>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (dramasSection == null) {
          final dramasResult = await multimediaUseCase.getHomeSection(5);
          dramasSection = dramasResult.data;
        }
        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
    on<_HomeEventLoadSectionKids>((event, emit) async {
      emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loading));
      try {
        if (kidsSection == null) {
          final kidsResult = await multimediaUseCase.getHomeSection(3);
          kidsSection = kidsResult.data;
        }
        emit(
            HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loaded(channels: selectedChannel, movies: moviesSection, series: seriesSection, animes: animesSection, dramas: dramasSection, kids: kidsSection, status: HomeStateStatus.error));
      }
    });
  }
}
