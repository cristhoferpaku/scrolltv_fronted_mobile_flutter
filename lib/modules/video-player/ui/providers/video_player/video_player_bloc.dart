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

  // Getter público para el controller (fallback para UI)
  VlcPlayerController? get controller => _controller;

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

  // Método para intentar inicialización con configuración simplificada
  Future<void> _trySimpleInitialization(String videoUrl, Emitter<VideoPlayerState> emit) async {
    try {
      print('🔄 Intentando inicialización simplificada...');

      // Dispose del controlador anterior
      _disposeController();

      // Crear controlador con configuración mínima
      final simpleController = VlcPlayerController.network(
        videoUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(1000),
          ]),
        ),
      );

      _controller = simpleController;

      // Listener de inicialización
      simpleController.addOnInitListener(() async {
        try {
          await simpleController.startRendererScanning();
          print('✅ Controlador simplificado inicializado');
        } catch (e) {
          print('⚠️ Error en scanning simplificado: $e');
        }
      });

      // Esperar inicialización con timeout reducido
      int attempts = 0;
      const maxAttempts = 50; // 5 segundos para el intento simplificado
      while (!simpleController.value.isInitialized && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (simpleController.value.isInitialized) {
        print('✅ Inicialización simplificada exitosa');
        emit(VideoPlayerState.loading(url: videoUrl));

        _setupListeners();
        _loadTracksWithRetry();
        print('🎬 Reproductor inicializado con configuración simplificada');
      } else {
        print('❌ Falló también la inicialización simplificada');
        emit(VideoPlayerState.error(message: 'No se pudo inicializar el reproductor. Verifique la conexión de red y el formato del video.'));
      }
    } catch (e) {
      print('💥 Error en inicialización simplificada: $e');
      emit(VideoPlayerState.error(message: 'Error crítico al inicializar el reproductor: $e'));
    }
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
          _controller?.dispose();
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

      // Usar la misma lógica simple del VideoControllerManager que funcionaba
      print('🔄 Inicializando reproductor con URL: ${event.videoUrl}');

      final controller = VlcPlayerController.network(
        event.videoUrl,
        hwAcc: HwAcc.auto,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(1000),
          ]),
          http: VlcHttpOptions([
            VlcHttpOptions.httpReconnect(true),
          ]),
        ),
      );

      _controller = controller;

      // Agregar listener de inicialización como en VideoControllerManager
      controller.addOnInitListener(() async {
        try {
          await controller.startRendererScanning();
        } catch (e) {
          print('⚠️ Error en startRendererScanning: $e');
        }
      });

      // Esperar a que el controlador VLC se inicialice con timeout extendido
      int attempts = 0;
      const maxAttempts = 150; // 15 segundos para HLS y CDN con latencia
      while (!controller.value.isInitialized && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;

        // Log de progreso cada 2 segundos
        if (attempts % 20 == 0) {
          print('⏳ Esperando inicialización... ${attempts * 100}ms');
        }

        // Emitir estado de loading con progreso cada 5 segundos
        if (attempts % 50 == 0) {
          emit(VideoPlayerState.loading(url: event.videoUrl));
        }
      }

      if (!controller.value.isInitialized) {
        print('❌ Controlador aún no inicializado después de ${maxAttempts * 100}ms');
        // Intentar una vez más con configuración simplificada
        await _trySimpleInitialization(event.videoUrl, emit);
        return;
      }

      // Emitir estado loading mientras el video se carga
      emit(VideoPlayerState.loading(url: event.videoUrl));

      // Setup listeners después de la inicialización (fuera del callback)
      _setupListeners();

      // Load tracks después de la inicialización (sin await para evitar bloqueo)
      _loadTracksWithRetry();

      print('🎬 Reproductor inicializado correctamente con URL: ${event.videoUrl}');
    } catch (e) {
      print('💥 Error crítico al inicializar el reproductor: $e');
      emit(VideoPlayerState.error(message: 'Error al inicializar el reproductor: $e'));
    }
  }

  void _setupListeners() {
    if (_controller == null) return;

    // Variable para controlar si ya se emitió el estado ready
    bool hasEmittedReady = false;
    // Crear el listener y almacenar la referencia
    _controllerListener = () {
      // Verificar que el controlador aún existe y está inicializado antes de acceder a sus propiedades
      if (_controller == null || !_controller!.value.isInitialized) {
        return;
      }

      try {
        // Verificar que el BLoC no esté cerrado antes de emitir eventos
        if (isClosed) return;
        final isPlaying = _controller!.value.isPlaying;
        final currentPosition = _controller!.value.position;
        final duration = _controller!.value.duration;

        // Detectar cuando el video está completamente cargado usando isBuffering
        final isBuffering = _controller!.value.isBuffering;

        // Log del estado de buffering para debugging
        if (isBuffering) {
          print('⏳ Video en buffering... Duración: ${duration.inSeconds}s, Reproduciendo: $isPlaying');
        }
        // Emitir estado 'ready' cuando el video no esté en buffering, esté reproduciendo y tenga duración
        if (!hasEmittedReady && !isBuffering && isPlaying && duration.inMilliseconds > 0) {
          hasEmittedReady = true;
          print('✅ Video cargado completamente - sin buffering y reproduciéndose');
          print('📊 Duración: ${duration.inSeconds}s');
          print('🎮 Buffering: $isBuffering');
          print('▶️ Reproduciendo: $isPlaying');

          // Obtener la URL del estado actual
          final currentState = state;
          String videoUrl = '';
          if (currentState is _VideoPlayerStateLoading) {
            videoUrl = currentState.url;
          }
          // Emitir estado ready con el controlador y la URL
          if (!isClosed && _controller != null) {
            emit(VideoPlayerState.ready(
              url: videoUrl,
              controller: _controller!,
              currentPosition: currentPosition,
              duration: duration,
              isPlaying: isPlaying,
            ));
          }
        }

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
    // Verificar que el controlador esté inicializado
    if (_controller == null || !_controller!.value.isInitialized) {
      print('⚠️ Controlador no inicializado, esperando...');
      // Esperar menos tiempo para inicialización
      await Future.delayed(const Duration(milliseconds: 300));

      if (_controller == null || !_controller!.value.isInitialized) {
        print('❌ Controlador aún no inicializado después de esperar');
        _addDefaultTracks();
        return;
      }
    }

    // Delay mínimo para asegurar que VLC esté listo
    await Future.delayed(const Duration(milliseconds: 200));

    // Primer intento inmediato
    final firstAttempt = await _loadVideoTracks();
    if (firstAttempt) {
      print('✅ Pistas cargadas exitosamente en el primer intento');
      return;
    }

    // Si el primer intento falla, hacer solo 2 intentos más con delays cortos
    // Esto es suficiente para la mayoría de casos y evita esperas innecesarias
    for (int attempt = 1; attempt < 3; attempt++) {
      print('⏳ Intento ${attempt + 1}, reintentando en 300ms...');
      await Future.delayed(const Duration(milliseconds: 300));

      final hasTracksLoaded = await _loadVideoTracks();
      if (hasTracksLoaded) {
        print('✅ Pistas cargadas exitosamente en el intento ${attempt + 1}');
        return;
      }
    }

    print('❌ No se encontraron pistas después de 3 intentos - usando pistas por defecto');
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

      // Try to get real subtitle tracks from VLC with timeout
      try {
        final spuCount = await _controller!.getSpuTracks().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            print('⏱️ Timeout obteniendo subtítulos - probablemente no hay pistas');
            return <int, String>{};
          },
        );

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

      // Try to get real audio tracks from VLC with timeout
      try {
        final audio = await _controller!.getAudioTracks().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            print('⏱️ Timeout obteniendo audio - probablemente no hay pistas múltiples');
            return <int, String>{};
          },
        );

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

      // Si encontramos pistas reales, las cargamos
      if (foundSubtitles || foundAudio) {
        // Verificar que el BLoC no esté cerrado antes de agregar evento
        if (!isClosed) {
          add(VideoPlayerEvent.tracksLoaded(
            subtitleTracks: subtitleList,
            audioTracks: audioList,
          ));
        }
        return true;
      }

      // Si no encontramos pistas después del primer intento,
      // es muy probable que el video no tenga pistas múltiples
      print('ℹ️ Video sin pistas múltiples detectado');
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

    // Verificar que el BLoC no esté cerrado antes de agregar evento
    if (!isClosed) {
      add(VideoPlayerEvent.tracksLoaded(
        subtitleTracks: defaultSubtitles,
        audioTracks: defaultAudio,
      ));
    }
  }

  Future<void> _onDispose(_VideoPlayerEventDispose event, Emitter<VideoPlayerState> emit) async {
    _disposeController();
    emit(const VideoPlayerState.initial());
  }

  Future<void> _onPlay(_VideoPlayerEventPlay event, Emitter<VideoPlayerState> emit) async {
    if (_controller?.value.isInitialized == true) {
      final currentState = state;
      if (currentState is _VideoPlayerStateReady && currentState.hasEnded) {
        // Si el video terminó, reiniciar desde el principio
        await _controller?.seekTo(Duration.zero);
      }
      await _controller?.play();
    } else {
      print('⚠️ Intento de reproducir controlador no inicializado');
    }
  }

  Future<void> _onPause(_VideoPlayerEventPause event, Emitter<VideoPlayerState> emit) async {
    if (_controller?.value.isInitialized == true) {
      await _controller?.pause();
    } else {
      print('⚠️ Intento de pausar controlador no inicializado');
    }
  }

  Future<void> _onTogglePlayPause(_VideoPlayerEventTogglePlayPause event, Emitter<VideoPlayerState> emit) async {
    final currentState = state;
    if (currentState is _VideoPlayerStateReady && _controller?.value.isInitialized == true) {
      if (currentState.isPlaying) {
        await _controller?.pause();
      } else {
        // Si el video terminó, reiniciar desde el principio
        if (currentState.hasEnded) {
          await _controller?.seekTo(Duration.zero);
        }
        await _controller?.play();
      }
    } else {
      print('⚠️ Intento de toggle play/pause en controlador no inicializado');
    }
  }

  Future<void> _onStop(_VideoPlayerEventStop event, Emitter<VideoPlayerState> emit) async {
    if (_controller?.value.isInitialized == true) {
      await _controller?.stop();
    } else {
      print('⚠️ Intento de detener controlador no inicializado');
    }
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
        if (!isClosed) {
          add(VideoPlayerEvent.error(message: 'Error changing subtitle track: $e'));
        }
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
        if (!isClosed) {
          add(VideoPlayerEvent.error(message: 'Error changing audio track: $e'));
        }
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
}
