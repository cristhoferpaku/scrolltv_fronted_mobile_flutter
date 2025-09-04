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
    List<VideoModel>? initialVideos;
    String search = "";
    on<SearchEvent>((event, emit) async {});
    on<_SearchEventStarted>((event, emit) async {
      add(_SearchEventClear()); //busqueda inicial
    });
    on<_SearchEventClear>((event, emit) async {
      search = "";
      emit(SearchState.loaded(status: SearchStateStatus.initial, videos: initialVideos, search: search));
    });
    on<_SearchEventSearch>((event, emit) async {
      try {
        emit(SearchState.loaded(status: SearchStateStatus.loadingVideos, videos: videos, search: search));
        final response = await multimediaUseCase.getVideosBySearch(event.search.isEmpty ? "a" : event.search);
        search = event.search;
        if (response.success) {
          videos = response.data;
          emit(SearchState.loaded(status: SearchStateStatus.loadedVideos, videos: videos, search: search));
        }
      } catch (e) {
        emit(SearchState.loaded(status: SearchStateStatus.error, videos: videos, search: search));
      }
    });
    on<_SearchEventGetInitialVideos>((event, emit) async {
      try {
        emit(SearchState.loaded(status: SearchStateStatus.loadingVideos, videos: videos, search: search));
        final response = await multimediaUseCase.getVideosBySearch("a");
        if (response.success) {
          videos = response.data;
          initialVideos = response.data;
          emit(SearchState.loaded(status: SearchStateStatus.loadedVideos, videos: videos, search: search));
        }
      } catch (e) {
        emit(SearchState.loaded(status: SearchStateStatus.error, videos: videos, search: search));
      }
    });
  }
}
