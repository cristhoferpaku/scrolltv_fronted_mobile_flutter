part of 'video_player_bloc.dart';

@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState.initial() = _Initial;
  const factory VideoPlayerState.loaded({
    required VideoPlayerStatus status,
    required String videourl,
    required int videoId,
    required bool showSubtitlePanel,
    required bool showAudioPanel,
    required bool showQualityPanel,
  }) = VideoPlayerStateLoaded;
}

enum VideoPlayerStatus {
  initial,
  loading,
  loaded,
  error,
}
