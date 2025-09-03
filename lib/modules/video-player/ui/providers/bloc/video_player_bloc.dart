import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_player_bloc.freezed.dart';
part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc() : super(_Initial()) {
    String videoUrl = "";
    int videoId = 0;

    bool showSubtitlePanel = false;
    bool showAudioPanel = false;
    bool showQualityPanel = false;

    on<VideoPlayerEvent>((event, emit) {});
    on<_VideoPlayerEventStarted>((event, emit) {
      videoUrl = event.videoUrl;
      videoId = event.videoId;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded, videourl: videoUrl, videoId: videoId, showSubtitlePanel: showSubtitlePanel, showAudioPanel: showAudioPanel, showQualityPanel: showQualityPanel));
    });
    on<_VideoPlayerEventShowSubtitlePanel>((event, emit) {
      showSubtitlePanel = event.value;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded, videourl: videoUrl, videoId: videoId, showSubtitlePanel: showSubtitlePanel, showAudioPanel: showAudioPanel, showQualityPanel: showQualityPanel));
    });
    on<_VideoPlayerEventShowAudioPanel>((event, emit) {
      showAudioPanel = event.value;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded, videourl: videoUrl, videoId: videoId, showSubtitlePanel: showSubtitlePanel, showAudioPanel: showAudioPanel, showQualityPanel: showQualityPanel));
    });
    on<_VideoPlayerEventShowQualityPanel>((event, emit) {
      showQualityPanel = event.value;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded, videourl: videoUrl, videoId: videoId, showSubtitlePanel: showSubtitlePanel, showAudioPanel: showAudioPanel, showQualityPanel: showQualityPanel));
    });
  }
}
