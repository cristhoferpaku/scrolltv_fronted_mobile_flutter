part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loaded({
    required HomeStateStatus status,
    List<ChannelModel>? channels,
    GetHomeSectionModel? movies,
    GetHomeSectionModel? series,
    GetHomeSectionModel? animes,
    GetHomeSectionModel? dramas,
    GetHomeSectionModel? kids,
  }) = HomeStateLoadedSections;
}

enum HomeStateStatus {
  loading,
  loadingChannels,
  loadingMovies,
  loadingSeries,
  loadingAnimes,
  loadingDramas,
  loadingKids,
  loaded,
  loadedChannels,
  loadedMovies,
  loadedSeries,
  loadedAnimes,
  loadedDramas,
  loadedKids,
  error,
}
