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
    List<Map<String, String>> subtitleOptions = [];
    List<Map<String, String>> audioOptions = [];
    List<Map<String, String>> qualityOptions = [];

    on<VideoPlayerEvent>((event, emit) {});
    on<_VideoPlayerEventStarted>((event, emit) {
      videoUrl = event.videoUrl;
      videoId = event.videoId;
      add(_VideoPlayerEventInitializeManagers());
    });
    on<_VideoPlayerEventInitializeManagers>((event, emit) {
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.initializeManagers,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });

    on<_VideoPlayerEventShowSubtitlePanel>((event, emit) {
      showSubtitlePanel = true;
      showAudioPanel = false;
      showQualityPanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventShowAudioPanel>((event, emit) {
      showAudioPanel = true;
      showSubtitlePanel = false;
      showQualityPanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventShowQualityPanel>((event, emit) {
      showQualityPanel = true;
      showSubtitlePanel = false;
      showAudioPanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventHideSubtitlePanel>((event, emit) {
      showSubtitlePanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventHideAudioPanel>((event, emit) {
      showAudioPanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventHideQualityPanel>((event, emit) {
      showQualityPanel = false;
      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventGetSubtitleOptions>((event, emit) {
      final subtitleTracks = event.subtitleTracks;

      if (subtitleTracks.isEmpty) {
        subtitleOptions = [
          {'label': 'No hay más subtítulos por el momento.', 'value': '0'}
        ];
      } else {
        subtitleOptions = subtitleTracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          return {'label': track['name'] ?? 'Subtítulo ${index + 1}', 'value': index.toString()};
        }).toList();
      }

      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });

    on<_VideoPlayerEventGetAudioOptions>((event, emit) {
      final audioTracks = event.audioTracks;

      if (audioTracks.isEmpty) {
        audioOptions = [
          {'label': 'No hay más audio por el momento.', 'value': '0'}
        ];
      } else {
        audioOptions = audioTracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          return {'label': track['name'] ?? 'Audio ${index + 1}', 'value': index.toString()};
        }).toList();
      }

      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
    on<_VideoPlayerEventGetQualityOptions>((event, emit) {
      final qualityLevels = event.qualityLevels;

      if (qualityLevels.isEmpty) {
        qualityOptions = [
          {'label': 'No hay más calidad por el momento.', 'value': '0'}
        ];
      } else {
        qualityOptions = qualityLevels.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;
          return {'label': level['name'] ?? 'Calidad ${index + 1}', 'value': index.toString()};
        }).toList();
      }

      emit(VideoPlayerState.loaded(
          status: VideoPlayerStatus.loaded,
          videourl: videoUrl,
          videoId: videoId,
          showSubtitlePanel: showSubtitlePanel,
          showAudioPanel: showAudioPanel,
          showQualityPanel: showQualityPanel,
          subtitleOptions: subtitleOptions,
          audioOptions: audioOptions,
          qualityOptions: qualityOptions));
    });
  }
}
