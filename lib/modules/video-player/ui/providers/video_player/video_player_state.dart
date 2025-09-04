part of 'video_player_bloc.dart';

@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState.initial() = _VideoPlayerStateInitial;
  
  const factory VideoPlayerState.loading({
    required String url,
  }) = _VideoPlayerStateLoading;
  
  const factory VideoPlayerState.ready({
    required String url,
    required VlcPlayerController controller,
    @Default(Duration.zero) Duration currentPosition,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isPlaying,
    @Default(false) bool hasEnded,
    @Default([]) List<Map<String, String>> subtitleTracks,
    @Default([]) List<Map<String, String>> audioTracks,
    @Default(0) int currentSubtitleIndex,
    @Default(0) int currentAudioIndex,
    @Default('') String currentSubtitle,
  }) = _VideoPlayerStateReady;
  
  const factory VideoPlayerState.error({
    required String message,
  }) = _VideoPlayerStateError;
}

extension VideoPlayerStateExtension on VideoPlayerState {
  VlcPlayerController? get controller => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => controller,
    orElse: () => null,
  );
  
  Duration get currentPosition => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => currentPosition,
    orElse: () => Duration.zero,
  );
  
  Duration get duration => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => duration,
    orElse: () => Duration.zero,
  );
  
  bool get isPlaying => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => isPlaying,
    orElse: () => false,
  );
  
  bool get hasEnded => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => hasEnded,
    orElse: () => false,
  );
  
  List<Map<String, String>> get subtitleTracks => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => subtitleTracks,
    orElse: () => [],
  );
  
  List<Map<String, String>> get audioTracks => maybeWhen(
    ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle) => audioTracks,
    orElse: () => [],
  );
  
  String? get errorMessage => maybeWhen(
    error: (message) => message,
    orElse: () => null,
  );
}
