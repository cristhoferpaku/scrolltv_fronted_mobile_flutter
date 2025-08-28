part of 'search_bloc.dart';

@freezed
class SearchEvent with _$SearchEvent {
  const factory SearchEvent.started() = _SearchEventStarted;
  const factory SearchEvent.search(String search) = _SearchEventSearch;
}
