part of 'video_player_bloc.dart';

@freezed
class VideoPlayerEvent with _$VideoPlayerEvent {
  // Initialization events
  const factory VideoPlayerEvent.loadedVideo({required int episodeNum, required String videoUrl}) = _VideoPlayerEventLoadedVideo;
  const factory VideoPlayerEvent.loadEpisodes({required int seasonId}) = _VideoPlayerEventLoadEpisodes;

  // Audio and Subtitle events
  const factory VideoPlayerEvent.loadAudioTracks() = _VideoPlayerEventLoadAudioTracks;
  const factory VideoPlayerEvent.loadSubtitleTracks() = _VideoPlayerEventLoadSubtitleTracks;
  const factory VideoPlayerEvent.changeAudioTrack({required int trackId}) = _VideoPlayerEventChangeAudioTrack;
  const factory VideoPlayerEvent.changeSubtitleTrack({required int trackId}) = _VideoPlayerEventChangeSubtitleTrack;
  const factory VideoPlayerEvent.getSubtitleOptions({required List<TrackOptionModel> subtitleTracks}) = _VideoPlayerEventGetSubtitleOptions;
  const factory VideoPlayerEvent.getAudioOptions({required List<TrackOptionModel> audioTracks}) = _VideoPlayerEventGetAudioOptions;

  // Episode events
  const factory VideoPlayerEvent.changeEpisode({required EpisodeModel episode}) = _VideoPlayerEventChangeEpisode;
  const factory VideoPlayerEvent.toggleEpisodesList() = _VideoPlayerEventToggleEpisodesList;

  // Controllers events
  const factory VideoPlayerEvent.play() = _VideoPlayerEventPlay;
  const factory VideoPlayerEvent.pause() = _VideoPlayerEventPause;
  const factory VideoPlayerEvent.togglePlayPause() = _VideoPlayerEventTogglePlayPause;
  const factory VideoPlayerEvent.stop() = _VideoPlayerEventStop;
  const factory VideoPlayerEvent.restart() = _VideoPlayerEventRestart;
  const factory VideoPlayerEvent.seekTo({required Duration position}) = _VideoPlayerEventSeekTo;
  const factory VideoPlayerEvent.skipForward({required int seconds}) = _VideoPlayerEventSkipForward;
  const factory VideoPlayerEvent.skipBackward({required int seconds}) = _VideoPlayerEventSkipBackward;

  const factory VideoPlayerEvent.ended() = _VideoPlayerEventEnded;
}
