part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = _HomeEventStarted;
  const factory HomeEvent.loadSectionLive() = _HomeEventLoadSectionLive;
  const factory HomeEvent.loadSectionMovies() = _HomeEventLoadSectionMovies;
  const factory HomeEvent.loadSectionSeries() = _HomeEventLoadSectionSeries;
  const factory HomeEvent.loadSectionAnimes() = _HomeEventLoadSectionAnimes;
  const factory HomeEvent.loadSectionDramas() = _HomeEventLoadSectionDramas;
  const factory HomeEvent.loadSectionKids() = _HomeEventLoadSectionKids;
}
