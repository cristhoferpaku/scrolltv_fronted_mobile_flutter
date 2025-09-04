import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_player_bloc.freezed.dart';
part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VlcPlayerController? _controller;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _positionTimer;

  VideoPlayerBloc() : super(const VideoPlayerState.initial()) {
    on<_VideoPlayerEventInitialize>(_onInitialize);
    on<_VideoPlayerEventDispose>(_onDispose);
    on<_VideoPlayerEventPlay>(_onPlay);
    on<_VideoPlayerEventPause>(_onPause);
    on<_VideoPlayerEventTogglePlayPause>(_onTogglePlayPause);
    on<_VideoPlayerEventStop>(_onStop);
    on<_VideoPlayerEventRestart>(_onRestart);
    on<_VideoPlayerEventSeekTo>(_onSeekTo);
    on<_VideoPlayerEventSkipForward>(_onSkipForward);
    on<_VideoPlayerEventSkipBackward>(_onSkipBackward);
    on<_VideoPlayerEventChangeSubtitleTrack>(_onChangeSubtitleTrack);
    on<_VideoPlayerEventChangeAudioTrack>(_onChangeAudioTrack);
    on<_VideoPlayerEventUpdatePosition>(_onUpdatePosition);
    on<_VideoPlayerEventUpdateDuration>(_onUpdateDuration);
    on<_VideoPlayerEventUpdatePlayingState>(_onUpdatePlayingState);
    on<_VideoPlayerEventVideoEnded>(_onVideoEnded);
    on<_VideoPlayerEventTracksLoaded>(_onTracksLoaded);
    on<_VideoPlayerEventError>(_onError);
  }

  @override
  Future<void> close() {
    _disposeController();
    return super.close();
  }

  void _disposeController() {
    _positionTimer?.cancel();
    _positionSubscription?.cancel();
    try {
      // Solo hacer dispose si el controlador está inicializado
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.dispose();
      }
    } catch (e) {
      // Ignorar errores de dispose en controladores no inicializados
      print('⚠️ Error al hacer dispose del controlador: $e');
    }
    _controller = null;
  }

  Future<void> _onInitialize(_VideoPlayerEventInitialize event, Emitter<VideoPlayerState> emit) async {
    try {
      emit(VideoPlayerState.loading(url: event.videoUrl));

      // Dispose previous controller if exists
      _disposeController();
      // Usar la misma lógica simple del VideoControllerManager que funcionaba
      print('🔄 Inicializando reproductor con URL: ${event.videoUrl}');
      
      final controller = VlcPlayerController.network(
        event.videoUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(), // Usar opciones simples como el VideoControllerManager
      );

      // Agregar listener de inicialización como en VideoControllerManager
      controller.addOnInitListener(() async {
        try {
          await controller.startRendererScanning();
          print('✅ Controlador VLC inicializado correctamente');
        } catch (e) {
          print('⚠️ Error en startRendererScanning: $e');
        }
      });

      // Esperar tiempo suficiente para la inicialización como en VideoControllerManager
      await Future.delayed(const Duration(milliseconds: 3000));

      _controller = controller;
      
      // Setup listeners
      _setupListeners();

      emit(VideoPlayerState.ready(
        url: event.videoUrl,
        controller: controller,
      ));

      // Load tracks with retry mechanism como en VideoControllerManager
      _loadTracksWithRetry();
      
      print('🎬 Reproductor inicializado correctamente con URL: ${event.videoUrl}');
    } catch (e) {
      print('💥 Error crítico al inicializar el reproductor: $e');
      emit(VideoPlayerState.error(message: 'Error al inicializar el reproductor: $e'));
    }
  }

  void _setupListeners() {
    if (_controller == null) return;

    // Add listener to VLC controller
    _controller!.addListener(() {
      final isPlaying = _controller!.value.isPlaying;
      final currentPosition = _controller!.value.position;
      final duration = _controller!.value.duration;

      // Update position
      add(VideoPlayerEvent.updatePosition(position: currentPosition));

      // Update duration
      add(VideoPlayerEvent.updateDuration(duration: duration));

      // Update playing state
      add(VideoPlayerEvent.updatePlayingState(isPlaying: isPlaying));

      // Check if video has ended
      if (duration.inMilliseconds > 0 && currentPosition.inMilliseconds >= duration.inMilliseconds - 1000) {
        add(VideoPlayerEvent.videoEnded());
      }
    });
  }

  Future<void> _loadTracksWithRetry() async {
    await Future.delayed(const Duration(seconds: 3));

    for (int attempt = 0; attempt < 5; attempt++) {
      final hasTracksLoaded = await _loadVideoTracks();
      if (hasTracksLoaded) {
        print('✅ Pistas cargadas exitosamente en el intento ${attempt + 1}');
        return;
      }

      if (attempt < 4) {
        print('⏳ Intento ${attempt + 1} fallido, reintentando en 2 segundos...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    print('❌ No se pudieron cargar las pistas después de 5 intentos');
    _addDefaultTracks();
  }

  Future<bool> _loadVideoTracks() async {
    if (_controller == null) return false;

    try {
      // En flutter_vlc_player, las pistas se obtienen de manera diferente
      // Por ahora, agregamos pistas por defecto
      final subtitleTracks = <int, String>{};
      final audioTracks = <int, String>{};

      bool foundSubtitles = false;
      bool foundAudio = false;

      print('\n=== INFORMACIÓN DE PISTAS DE VIDEO ===');

      // Process subtitles
      if (subtitleTracks.isNotEmpty) {
        print('📝 SUBTÍTULOS ENCONTRADOS: ${subtitleTracks.length} pistas');
        for (var track in subtitleTracks.entries) {
          print('   ID: ${track.key} - Nombre: ${track.value}');
        }
        foundSubtitles = true;
      } else {
        print('❌ No se encontraron pistas de subtítulos');
      }

      // Process audio tracks
      if (audioTracks.isNotEmpty) {
        print('🔊 AUDIOS ENCONTRADOS: ${audioTracks.length} pistas');
        for (var track in audioTracks.entries) {
          print('   ID: ${track.key} - Nombre: ${track.value}');
        }
        foundAudio = true;
      } else {
        print('❌ No se encontraron pistas de audio específicas');
      }

      print('=====================================\n');

      if (foundSubtitles || foundAudio) {
        // Convert to List<Map<String, String>> format
        final subtitleList = subtitleTracks.entries.map((e) => {'id': e.key.toString(), 'name': e.value}).toList();
        final audioList = audioTracks.entries.map((e) => {'id': e.key.toString(), 'name': e.value}).toList();

        add(VideoPlayerEvent.tracksLoaded(
          subtitleTracks: subtitleList,
          audioTracks: audioList,
        ));
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error al cargar pistas: $e');
      return false;
    }
  }

  void _addDefaultTracks() {
    final defaultSubtitles = [
      {'id': '-1', 'name': 'Sin subtítulos'}
    ];
    final defaultAudio = [
      {'id': '-1', 'name': 'Audio principal'}
    ];

    add(VideoPlayerEvent.tracksLoaded(
      subtitleTracks: defaultSubtitles,
      audioTracks: defaultAudio,
    ));
  }

  Future<void> _onDispose(_VideoPlayerEventDispose event, Emitter<VideoPlayerState> emit) async {
    _disposeController();
    emit(const VideoPlayerState.initial());
  }

  Future<void> _onPlay(_VideoPlayerEventPlay event, Emitter<VideoPlayerState> emit) async {
    await _controller?.play();
  }

  Future<void> _onPause(_VideoPlayerEventPause event, Emitter<VideoPlayerState> emit) async {
    await _controller?.pause();
  }

  Future<void> _onTogglePlayPause(_VideoPlayerEventTogglePlayPause event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      if (currentState.isPlaying) {
        await _controller?.pause();
      } else {
        await _controller?.play();
      }
    }
  }

  Future<void> _onStop(_VideoPlayerEventStop event, Emitter<VideoPlayerState> emit) async {
    await _controller?.stop();
  }

  Future<void> _onRestart(_VideoPlayerEventRestart event, Emitter<VideoPlayerState> emit) async {
    await _controller?.seekTo(Duration.zero);
    await _controller?.play();
  }

  Future<void> _onSeekTo(_VideoPlayerEventSeekTo event, Emitter<VideoPlayerState> emit) async {
    await _controller?.seekTo(event.position);
  }

  Future<void> _onSkipForward(_VideoPlayerEventSkipForward event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      final newPosition = currentState.currentPosition + Duration(seconds: event.seconds);
      final maxPosition = currentState.duration;
      final targetPosition = newPosition > maxPosition ? maxPosition : newPosition;
      await _controller?.seekTo(targetPosition);
    }
  }

  Future<void> _onSkipBackward(_VideoPlayerEventSkipBackward event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      final newPosition = currentState.currentPosition - Duration(seconds: event.seconds);
      final targetPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
      await _controller?.seekTo(targetPosition);
    }
  }

  Future<void> _onChangeSubtitleTrack(_VideoPlayerEventChangeSubtitleTrack event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      try {
        await _controller?.setSpuTrack(event.index);

        String? currentSubtitle;
        if (event.index >= 0 && event.index < currentState.subtitleTracks.length) {
          currentSubtitle = currentState.subtitleTracks[event.index]['name'];
        }

        emit(currentState.copyWith(
          currentSubtitleIndex: event.index,
          currentSubtitle: currentSubtitle ?? '',
        ));
      } catch (e) {
        add(VideoPlayerEvent.error(message: 'Error changing subtitle track: $e'));
      }
    }
  }

  Future<void> _onChangeAudioTrack(_VideoPlayerEventChangeAudioTrack event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      try {
        await _controller?.setAudioTrack(event.index);

        emit(currentState.copyWith(
          currentAudioIndex: event.index,
        ));
      } catch (e) {
        add(VideoPlayerEvent.error(message: 'Error changing audio track: $e'));
      }
    }
  }

  void _onUpdatePosition(_VideoPlayerEventUpdatePosition event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(currentPosition: event.position));
    }
  }

  void _onUpdateDuration(_VideoPlayerEventUpdateDuration event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(duration: event.duration));
    }
  }

  void _onUpdatePlayingState(_VideoPlayerEventUpdatePlayingState event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(isPlaying: event.isPlaying, hasEnded: false));
    }
  }

  void _onVideoEnded(_VideoPlayerEventVideoEnded event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(isPlaying: false, hasEnded: true));
    }
  }

  void _onTracksLoaded(_VideoPlayerEventTracksLoaded event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(
        subtitleTracks: event.subtitleTracks,
        audioTracks: event.audioTracks,
      ));
    }
  }

  void _onError(_VideoPlayerEventError event, Emitter<VideoPlayerState> emit) {
    emit(VideoPlayerState.error(message: event.message));
  }

  // Helper methods
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
