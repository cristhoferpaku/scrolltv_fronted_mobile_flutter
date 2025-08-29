part of 'search_bloc.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loaded({required SearchStateStatus status, required List<VideoModel>? videos, required String search}) = SearchStateLoaded;
}

enum SearchStateStatus {
  initial,
  loading,
  loadingVideos,
  loaded,
  loadedVideos,
  error,
}
