part of 'video_player_bloc.dart';

@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState.initial() = _Initial;
  const factory VideoPlayerState.loading() = VideoPlayerStateLoading;
  const factory VideoPlayerState.loaded() = VideoPlayerStateLoaded;
  const factory VideoPlayerState.error() = VideoPlayerStateError;
}
