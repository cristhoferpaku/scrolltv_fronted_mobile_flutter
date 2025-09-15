part of 'video_player_bloc.dart';

@freezed
class VideoPlayerEvent with _$VideoPlayerEvent {
  // Initialization events
  const factory VideoPlayerEvent.initialize({required String videoUrl}) = _VideoPlayerEventInitialize;
  const factory VideoPlayerEvent.dispose() = _VideoPlayerEventDispose;

  // Playback control events
  const factory VideoPlayerEvent.play() = _VideoPlayerEventPlay;
  const factory VideoPlayerEvent.pause() = _VideoPlayerEventPause;
  const factory VideoPlayerEvent.togglePlayPause() = _VideoPlayerEventTogglePlayPause;
  const factory VideoPlayerEvent.stop() = _VideoPlayerEventStop;
  const factory VideoPlayerEvent.restart() = _VideoPlayerEventRestart;

  // Seeking events
  const factory VideoPlayerEvent.seekTo({required Duration position}) = _VideoPlayerEventSeekTo;
  const factory VideoPlayerEvent.skipForward({required int seconds}) = _VideoPlayerEventSkipForward;
  const factory VideoPlayerEvent.skipBackward({required int seconds}) = _VideoPlayerEventSkipBackward;

  // Track selection events
  const factory VideoPlayerEvent.changeSubtitleTrack({required int index}) = _VideoPlayerEventChangeSubtitleTrack;
  const factory VideoPlayerEvent.changeAudioTrack({required int index}) = _VideoPlayerEventChangeAudioTrack;

  // Internal events
  const factory VideoPlayerEvent.updatePosition({required Duration position}) = _VideoPlayerEventUpdatePosition;
  const factory VideoPlayerEvent.updateDuration({required Duration duration}) = _VideoPlayerEventUpdateDuration;
  const factory VideoPlayerEvent.updatePlayingState({required bool isPlaying}) = _VideoPlayerEventUpdatePlayingState;
  const factory VideoPlayerEvent.videoEnded() = _VideoPlayerEventVideoEnded;
  const factory VideoPlayerEvent.tracksLoaded({
    required List<Map<String, String>> subtitleTracks,
    required List<Map<String, String>> audioTracks,
  }) = _VideoPlayerEventTracksLoaded;

  // Episodes events
  const factory VideoPlayerEvent.loadEpisodes({required int seasonId}) = _VideoPlayerEventLoadEpisodes;

  // Error events
  const factory VideoPlayerEvent.error({required String message}) = _VideoPlayerEventError;
}
