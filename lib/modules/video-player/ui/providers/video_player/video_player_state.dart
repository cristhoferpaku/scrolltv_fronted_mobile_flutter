part of 'video_player_bloc.dart';

@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState.initial() = _Initial;
  const factory VideoPlayerState.loading() = _Loading;
  const factory VideoPlayerState.loaded({
    required String videoUrl,
    required VlcPlayerController controller,
    required VideoPlayerStatus status,
    @Default(false) bool isPlaying,
    @Default(false) bool hasEnded,
    @Default([]) List<EpisodeModel> episodes,
    @Default(1) int episodeIndex,
    @Default(false) bool showEpisodesList,
    @Default(false) bool isLoading,
    @Default(Duration.zero) Duration currentPosition,
    @Default(Duration.zero) Duration duration,
    @Default([]) List<TrackOptionModel> subtitles,
    @Default([]) List<TrackOptionModel> audioTracks,
    @Default(false) bool showSubtitlePanel,
    @Default(false) bool showAudioPanel,
    @Default(0) int selectedSubtitleIndex,
    @Default(0) int selectedAudioIndex,
    @Default(0) int currentSubtitleIndex,
    @Default(0) int currentAudioIndex,
    // Propiedades para conectividad
    @Default(true) bool hasConnectivity,
    @Default(false) bool isReconnecting,
  }) = VideoPlayerStateLoaded;

  // Nuevos estados para conectividad
  const factory VideoPlayerState.connectionLost({
    required String lastVideoUrl,
    required int lastEpisodeNum,
    required Duration lastPosition,
  }) = VideoPlayerStateConnectionLost;

  const factory VideoPlayerState.reconnecting({
    required String videoUrl,
    required int episodeNum,
    required Duration lastPosition,
  }) = VideoPlayerStateReconnecting;

  const factory VideoPlayerState.error(String message) = VideoPlayerStateError;
}

enum VideoPlayerStatus {
  inicialiced,
  loading,
  loaded,
  loadingSubtitles,
  loadedSubtitles,
  loadingEpisodes,
  loadedEpisodes,
  loadingAudio,
  loadedAudio,
}
