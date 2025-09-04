part of 'video_player_bloc.dart';

@freezed
class VideoPlayerEvent with _$VideoPlayerEvent {
  const factory VideoPlayerEvent.started({required int videoId, required String videoUrl}) = _VideoPlayerEventStarted;
  const factory VideoPlayerEvent.initializeManagers() = _VideoPlayerEventInitializeManagers;
  const factory VideoPlayerEvent.showSubtitlePanel() = _VideoPlayerEventShowSubtitlePanel;
  const factory VideoPlayerEvent.showAudioPanel() = _VideoPlayerEventShowAudioPanel;
  const factory VideoPlayerEvent.showQualityPanel() = _VideoPlayerEventShowQualityPanel;
  const factory VideoPlayerEvent.hideSubtitlePanel() = _VideoPlayerEventHideSubtitlePanel;
  const factory VideoPlayerEvent.hideAudioPanel() = _VideoPlayerEventHideAudioPanel;
  const factory VideoPlayerEvent.hideQualityPanel() = _VideoPlayerEventHideQualityPanel;
  const factory VideoPlayerEvent.getSubtitleOptions({required List<Map<String, String>> subtitleTracks}) = _VideoPlayerEventGetSubtitleOptions;
  const factory VideoPlayerEvent.getAudioOptions({required List<Map<String, String>> audioTracks}) = _VideoPlayerEventGetAudioOptions;
  const factory VideoPlayerEvent.getQualityOptions({required List<Map<String, String>> qualityLevels}) = _VideoPlayerEventGetQualityOptions;
}
