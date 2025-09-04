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
    required List<Map<String, String>> subtitleOptions,
    required List<Map<String, String>> audioOptions,
    required List<Map<String, String>> qualityOptions,
  }) = VideoPlayerStateLoaded;
}

enum VideoPlayerStatus {
  initial,
  loading,
  initializeManagers,
  loaded,
  setManagers,
  error,
}
