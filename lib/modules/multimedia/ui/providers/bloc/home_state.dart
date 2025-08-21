part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loadedSections(
      GetHomeSectionModel? movies,
      GetHomeSectionModel? series,
      GetHomeSectionModel? animes,
      GetHomeSectionModel? dramas,
      GetHomeSectionModel? kids,
      HomeStateStatus status) = HomeStateLoadedSections;
}
