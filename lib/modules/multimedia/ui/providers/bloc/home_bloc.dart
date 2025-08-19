import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';

import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/constants/types/home_state_status.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(_Initial()) {
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    GetHomeSectionModel? moviesSection;
    GetHomeSectionModel? seriesSection;
    GetHomeSectionModel? animesSection;
    GetHomeSectionModel? dramasSection;
    GetHomeSectionModel? kidsSection;

    on<_HomeEventStarted>((event, emit) async {
      emit(HomeState.loadedSections(moviesSection, seriesSection, animesSection,
          dramasSection, kidsSection, HomeStateStatus.loading));
      try {
        final moviesResult = await multimediaUseCase.getHomeSection(1);
        final seriesResult = await multimediaUseCase.getHomeSection(2);
        final kidsResult = await multimediaUseCase.getHomeSection(3);
        final animesResult = await multimediaUseCase.getHomeSection(4);
        final dramasResult = await multimediaUseCase.getHomeSection(5);

        moviesSection = moviesResult.data;
        seriesSection = seriesResult.data;
        animesSection = animesResult.data;
        dramasSection = dramasResult.data;
        kidsSection = kidsResult.data;

        emit(HomeState.loadedSections(moviesSection, seriesSection,
            animesSection, dramasSection, kidsSection, HomeStateStatus.loaded));
      } catch (e) {
        emit(HomeState.loadedSections(moviesSection, seriesSection,
            animesSection, dramasSection, kidsSection, HomeStateStatus.error));
      }
    });
  }
}
