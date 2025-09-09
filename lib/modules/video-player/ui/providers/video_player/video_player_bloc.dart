import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';

part 'video_player_bloc.freezed.dart';
part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VlcPlayerController? _controller;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _positionTimer;
  VoidCallback? _controllerListener;
  final MultimediaUseCase _multimediaUseCase = instance<MultimediaUseCase>();

  // Caché para episodios por seasonId
  final Map<int, List<EpisodeModel>> _episodesCache = {};
  int? _currentSeasonId;

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
    on<_VideoPlayerEventLoadEpisodes>(_onLoadEpisodes);
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

    if (_controller != null) {
      try {
        // Remover el listener específico si existe
        if (_controllerListener != null) {
          _controller!.removeListener(_controllerListener!);
          _controllerListener = null;
        }

        // Solo hacer dispose si el controlador está inicializado
        if (_controller!.value.isInitialized) {
          _controller!.dispose();
        }
      } catch (e) {
        // Ignorar errores de dispose en controladores no inicializados
        print('⚠️ Error al hacer dispose del controlador: $e');
      } finally {
        // Asegurar que el controlador se establezca como null
        _controller = null;
      }
    }
  }

  Future<void> _onInitialize(_VideoPlayerEventInitialize event, Emitter<VideoPlayerState> emit) async {
    try {
      emit(VideoPlayerState.loading(url: event.videoUrl));

      // Dispose previous controller if exists
      _disposeController();

      // Esperar un momento para asegurar que el dispose anterior se complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Usar la misma lógica simple del VideoControllerManager que funcionaba
      print('🔄 Inicializando reproductor con URL: ${event.videoUrl}');

      final controller = VlcPlayerController.network(
        event.videoUrl,
        hwAcc: HwAcc.auto, // HwAcc.auto funciona mejor en dispositivos móviles
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

    // Crear el listener y almacenar la referencia
    _controllerListener = () {
      // Verificar que el controlador aún existe y está inicializado antes de acceder a sus propiedades
      if (_controller == null || !_controller!.value.isInitialized) {
        return;
      }

      try {
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
      } catch (e) {
        // Ignorar errores cuando el controlador está siendo dispuesto
        print('⚠️ Error en listener del controlador (probablemente durante dispose): $e');
      }
    };

    // Add listener to VLC controller
    _controller!.addListener(_controllerListener!);
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
      bool foundSubtitles = false;
      bool foundAudio = false;
      final subtitleList = <Map<String, String>>[];
      final audioList = <Map<String, String>>[];

      print('\n=== INFORMACIÓN DE PISTAS DE VIDEO ===');

      // Try to get real subtitle tracks from VLC (same as VideoControllerManager)
      try {
        final spuCount = await _controller!.getSpuTracks();
        // Add "Desactivados" option first
        subtitleList.add({'id': '-1', 'name': 'Desactivados'});
        if (spuCount.isNotEmpty) {
          final sortedTracks = spuCount.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
          // Add real subtitle tracks from video stream in alphabetical order
          for (final entry in sortedTracks) {
            subtitleList.add({'id': entry.key.toString(), 'name': entry.value});
          }
          foundSubtitles = true;
          print('📝 SUBTÍTULOS ENCONTRADOS: ${spuCount.length} pistas');
          for (var track in spuCount.entries) {
            print('   ID: ${track.key} - Nombre: ${track.value}');
          }
        } else {
          print('❌ No se encontraron pistas de subtítulos');
        }
      } catch (e) {
        subtitleList.add({'id': '-1', 'name': 'Desactivados'});
        print('❌ Error obteniendo subtítulos: $e');
      }

      // Try to get real audio tracks from VLC (same as VideoControllerManager)
      try {
        final audio = await _controller!.getAudioTracks();
        if (audio.isNotEmpty) {
          final sortedAudioTracks = audio.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
          for (final entry in sortedAudioTracks) {
            audioList.add({'id': entry.key.toString(), 'name': entry.value});
          }
          foundAudio = true;
          print('🔊 AUDIOS ENCONTRADOS: ${audio.length} pistas');
          for (var track in audio.entries) {
            print('   ID: ${track.key} - Nombre: ${track.value}');
          }
        } else {
          print('❌ No se encontraron pistas de audio específicas');
        }
      } catch (e) {
        print('❌ Error obteniendo audio: $e');
      }

      print('=====================================\n');

      if (foundSubtitles || foundAudio) {
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
      {'id': '-1', 'name': 'Desactivados'}
    ];
    final defaultAudio = [
      {'id': '0', 'name': 'Audio Principal'}
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
    final currentState = state;
    if (currentState is _VideoPlayerStateReady && currentState.hasEnded) {
      // Si el video terminó, reiniciar desde el principio
      await _controller?.seekTo(Duration.zero);
    }
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
        // Si el video terminó, reiniciar desde el principio
        if (currentState.hasEnded) {
          await _controller?.seekTo(Duration.zero);
        }
        await _controller?.play();
      }
    }
  }

  Future<void> _onStop(_VideoPlayerEventStop event, Emitter<VideoPlayerState> emit) async {
    await _controller?.stop();
  }

  Future<void> _onRestart(_VideoPlayerEventRestart event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady && currentState.hasEnded) {
      // Si el video terminó, primero hacer stop para resetear el estado
      await _controller?.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }
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
        // Obtener el ID real de la pista desde el array
        String? trackId;
        String? currentSubtitle;

        if (event.index >= 0 && event.index < currentState.subtitleTracks.length) {
          trackId = currentState.subtitleTracks[event.index]['id'];
          currentSubtitle = currentState.subtitleTracks[event.index]['name'];
        }

        // Usar el ID real de la pista, no el índice del array
        if (trackId != null) {
          final realTrackId = int.tryParse(trackId) ?? -1;
          await _controller?.setSpuTrack(realTrackId);
          print('🎬 Cambiando subtítulo a pista ID: $realTrackId (índice: ${event.index})');
        }

        emit(currentState.copyWith(
          currentSubtitleIndex: event.index,
          currentSubtitle: currentSubtitle ?? '',
        ));
      } catch (e) {
        print('❌ Error cambiando pista de subtítulos: $e');
        add(VideoPlayerEvent.error(message: 'Error changing subtitle track: $e'));
      }
    }
  }

  Future<void> _onChangeAudioTrack(_VideoPlayerEventChangeAudioTrack event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      try {
        // Obtener el ID real de la pista desde el array
        String? trackId;

        if (event.index >= 0 && event.index < currentState.audioTracks.length) {
          trackId = currentState.audioTracks[event.index]['id'];
        }

        // Usar el ID real de la pista, no el índice del array
        if (trackId != null) {
          final realTrackId = int.tryParse(trackId) ?? 0;
          await _controller?.setAudioTrack(realTrackId);
          print('🎵 Cambiando audio a pista ID: $realTrackId (índice: ${event.index})');
        }

        emit(currentState.copyWith(
          currentAudioIndex: event.index,
        ));
      } catch (e) {
        print('❌ Error cambiando pista de audio: $e');
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

  void _onVideoEnded(_VideoPlayerEventVideoEnded event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      emit(currentState.copyWith(isPlaying: false, hasEnded: true));

      // Fix para el bug de flutter_vlc_player: cuando el video termina,
      // el controller queda en un estado donde no puede volver a reproducir.
      // La solución es hacer stop() para resetear el estado interno de libVLC.
      try {
        await _controller?.stop();
        print('🔄 Video terminado - Controller reseteado para permitir reproducción futura');
      } catch (e) {
        print('⚠️ Error al resetear controller después de video terminado: $e');
      }
    }
  }

  void _onTracksLoaded(_VideoPlayerEventTracksLoaded event, Emitter<VideoPlayerState> emit) {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      // Inicializar con los índices por defecto
      // Subtítulos: índice 0 ("Desactivados")
      // Audio: índice 0 ("Audio Principal")
      emit(currentState.copyWith(
        subtitleTracks: event.subtitleTracks,
        audioTracks: event.audioTracks,
        currentSubtitleIndex: 0,
        currentAudioIndex: 0,
        tracksLoaded: true,
      ));
    }
  }

  void _onLoadEpisodes(_VideoPlayerEventLoadEpisodes event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady) {
      // Verificar si ya tenemos los episodios en caché para este seasonId
      if (_episodesCache.containsKey(event.seasonId) && _currentSeasonId == event.seasonId) {
        print('📋 Episodios obtenidos desde caché para seasonId: ${event.seasonId}');
        emit(currentState.copyWith(episodes: _episodesCache[event.seasonId]!));
        return;
      }

      // Si no están en caché o es un seasonId diferente, cargar desde API
      print('🌐 Cargando episodios desde API para seasonId: ${event.seasonId}');
      final episodes = await _generateStaticEpisodes(event.seasonId);

      // Guardar en caché
      _episodesCache[event.seasonId] = episodes;
      _currentSeasonId = event.seasonId;

      emit(currentState.copyWith(episodes: episodes));
    }
  }

  Future<List<EpisodeModel>> _generateStaticEpisodes(int seasonId) async {
    // Obtener episodios reales usando el seasonId y mapper
    final response = await _multimediaUseCase.getEpisodesBySeasonId(seasonId);
    return response.data;
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
