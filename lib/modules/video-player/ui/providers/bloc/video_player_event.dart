part of 'video_player_bloc.dart';

@freezed
class VideoPlayerEvent with _$VideoPlayerEvent {
  const factory VideoPlayerEvent.started({required int videoId, required String videoUrl}) = _VideoPlayerEventStarted;
  const factory VideoPlayerEvent.showSubtitlePanel(bool value) = _VideoPlayerEventShowSubtitlePanel;
  const factory VideoPlayerEvent.showAudioPanel(bool value) = _VideoPlayerEventShowAudioPanel;
  const factory VideoPlayerEvent.showQualityPanel(bool value) = _VideoPlayerEventShowQualityPanel;
}
