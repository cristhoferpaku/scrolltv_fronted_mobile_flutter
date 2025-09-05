part of 'tv_player_bloc.dart';

@freezed
class TvPlayerState with _$TvPlayerState {
  const factory TvPlayerState({required TVPlayerStatus status, required List<Map<String, String>> channels, required int selectedChannelIndex}) = _TvPlayerState;
}

enum TVPlayerStatus {
  initial,
  loading,
  loaded,
  success,
  error,
}
