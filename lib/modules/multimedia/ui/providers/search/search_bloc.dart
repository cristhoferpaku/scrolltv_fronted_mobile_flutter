import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';

part 'search_bloc.freezed.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(_Initial()) {
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    List<VideoModel>? videos;
    on<SearchEvent>((event, emit) async {});
    on<_SearchEventStarted>((event, emit) async {
      emit(SearchState.loaded(status: SearchStateStatus.initial, videos: []));
    });
    on<_SearchEventSearch>((event, emit) async {
      try {
        emit(SearchState.loaded(status: SearchStateStatus.loadingVideos, videos: videos));
        await Future.delayed(const Duration(seconds: 1));
        final response = await multimediaUseCase.getVideosBySearch(event.search);
        if (response.success) {
          videos = response.data;
          emit(SearchState.loaded(status: SearchStateStatus.loadedVideos, videos: videos));
        }
      } catch (e) {
        emit(SearchState.loaded(status: SearchStateStatus.error, videos: videos));
      }
    });
  }
}
