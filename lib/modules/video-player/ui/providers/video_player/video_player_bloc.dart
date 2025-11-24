import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/domain/track_option_model.dart';

part 'video_player_bloc.freezed.dart';
part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VlcPlayerController? controller;
  final MultimediaUseCase _multimediaUseCase = instance<MultimediaUseCase>();

  // Variables para manejo de conectividad
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _lastVideoUrl;
  int? _lastEpisodeNum;
  Duration? _lastPosition;
  bool _hasConnectivity = true;

  // Variables para preservar pistas de audio y subtítulos
  int? _lastAudioTrack;
  int? _lastSubtitleTrack;

  // Variables para controlar el seeking
  final bool _isSeeking = false;
  Timer? _seekingTimer;
  Duration? _pendingSeekPosition;
  Duration? _accumulatedSeekPosition;
  int _seekCount = 0;
  bool _preferredAppliedOnce = false;
  bool _postPlayApplied = false;

  VideoPlayerBloc() : super(const VideoPlayerState.initial()) {
    // Caché para episodios por seasonId
    final Map<int, List<EpisodeModel>> episodesCache = {};
    // int? currentSeasonId;

    // Inicializar monitoreo de conectivida
    _initConnectivityMonitoring();

    on<VideoPlayerEvent>((event, emit) {});

    on<_VideoPlayerEventLoadedVideo>((event, emit) async {
      try {
        // Guardar las pistas actuales antes de destruir el controlador
        _saveCurrentTracks();

        await controller?.stop();
        await controller?.dispose();
        _preferredAppliedOnce = false;
        _postPlayApplied = false;

        // Guardar información para reconexión
        _lastVideoUrl = event.videoUrl;
        _lastEpisodeNum = event.episodeNum;

        controller = VlcPlayerController.network(
          event.videoUrl,
          hwAcc: HwAcc.auto,
          autoPlay: true,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              '--network-caching=3000', // 3s cache para conexiones lentas
              '--http-reconnect', // Reconectar automáticamente
            ]),
          ),
        );

        // Configurar listeners para posición y duración
        _setupPositionListeners();
        await _applyPreferredTracks();
        // Esperar un momento para que VLC intente cargar el video
        await Future.delayed(const Duration(milliseconds: 500));

        // Verificar si el controlador se inicializó correctamente
        if (controller != null) {
          emit(
            VideoPlayerState.loaded(
              status: VideoPlayerStatus.loaded,
              videoUrl: event.videoUrl,
              controller: controller!,
              episodeIndex: event.episodeNum,
              showAudioPanel: false,
              showSubtitlePanel: false,
              isPlaying: true,
              hasConnectivity: _hasConnectivity,
              currentAudioIndex: _lastAudioTrack ?? 0,
              currentSubtitleIndex: _lastSubtitleTrack ?? -1,
            ),
          );

          // Restaurar las pistas después de emitir el estado
        } else {
          emit(VideoPlayerState.error('No se pudo inicializar el reproductor'));
        }
      } catch (e) {
        emit(VideoPlayerState.error('Error cargando video: ${e.toString()}'));
      }
    });

    // Evento: cargar episodios
    on<_VideoPlayerEventLoadEpisodes>((event, emit) async {
      //  emit(const VideoPlayerState.loading());
      final currentState = state;
      try {
        if (currentState is VideoPlayerStateLoaded) {
          emit(currentState.copyWith(
            status: VideoPlayerStatus.loadingEpisodes,
          ));
          List<EpisodeModel> episodes;
          if (episodesCache.containsKey(event.seasonId)) {
            episodes = episodesCache[event.seasonId]!;
          } else {
            final response = await _multimediaUseCase.getEpisodesBySeasonId(event.seasonId);
            episodes = response.data;
            episodesCache[event.seasonId] = episodes; // Guardar en caché
          }

          emit(currentState.copyWith(
            episodes: episodes,
            showEpisodesList: episodes.isNotEmpty, // Mostrar lista si hay episodios
            status: VideoPlayerStatus.loadedEpisodes,
          ));
        }
      } catch (e) {
        if (currentState is VideoPlayerStateLoaded) {
          emit(currentState.copyWith(
            episodes: [],
            showEpisodesList: false,
            showAudioPanel: false,
            showSubtitlePanel: false,
            status: VideoPlayerStatus.loaded,
          ));
        } else {
          emit(VideoPlayerState.error('Error cargando episodios: $e'));
        }
      }
    });

    // Evento: cambiar episodio con debounce
    on<_VideoPlayerEventChangeEpisode>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded) {
        // Guardar las pistas actuales antes de cambiar episodio
        _saveCurrentTracks();

        emit(currentState.copyWith(
          status: VideoPlayerStatus.loading,
          isLoading: true,
          showEpisodesList: false, // Cerrar la lista al cambiar episodio
          episodeIndex: event.episode.episodeNumber ?? 1,
        ));
        _preferredAppliedOnce = false;
        _postPlayApplied = false;
        try {
          if (controller != null) {
            // Limpiar listener anterior antes de cambiar el media
            controller!.removeListener(_onVlcPlayerValueChanged);
            // Intentar cambiar el media sin destruir el controller
            try {
              // Opcional: aumentar caché por si la red es inestable
              await Future.delayed(const Duration(milliseconds: 300));
              await controller!.setMediaFromNetwork(
                event.episode.videoUrl ?? '',
                autoPlay: true,
                // si tu versión lo soporta, puedes pasar opciones aquí
              );
              await _applyPreferredTracks();
            } catch (e) {
              // fallback: si setMediaFromNetwork falla, recreamos de forma segura
              try {
                await controller?.stop();
                await controller?.dispose();
              } catch (_) {}
              controller = VlcPlayerController.network(
                event.episode.videoUrl ?? '',
                hwAcc: HwAcc.auto,
                autoPlay: true,
                options: VlcPlayerOptions(
                  advanced: VlcAdvancedOptions([
                    '--network-caching=2000', // 2s cache
                    '--http-reconnect', // Reconectar automáticamente
                  ]),
                ),
              );
            }
          } else {
            // No hay controller todavía -> crear uno con caching
            controller = VlcPlayerController.network(
              event.episode.videoUrl ?? '',
              hwAcc: HwAcc.auto,
              autoPlay: true,
              options: VlcPlayerOptions(
                advanced: VlcAdvancedOptions(['--network-caching=2000', '--http-reconnect']),
              ),
            );
          }

          // Configurar listeners para el nuevo controlador
          _setupPositionListeners();

          // Emitir estado actualizado (asegúrate de tomar latest state)
          final latest = state;
          if (latest is VideoPlayerStateLoaded) {
            emit(latest.copyWith(
              videoUrl: event.episode.videoUrl ?? '',
              controller: controller!,
              //   episodeIndex: event.episode.episodeNumber ?? 1,
              status: VideoPlayerStatus.loaded,
              showEpisodesList: false,
              showAudioPanel: false,
              showSubtitlePanel: false,
              isLoading: false,
              currentAudioIndex: _lastAudioTrack ?? latest.currentAudioIndex,
              currentSubtitleIndex: _lastSubtitleTrack ?? latest.currentSubtitleIndex,
            ));
          } else {
            // si por alguna razón el state cambió, emitir loaded nuevo
            emit(VideoPlayerState.loaded(
              status: VideoPlayerStatus.loaded,
              videoUrl: event.episode.videoUrl ?? '',
              controller: controller!,
              //episodeIndex: event.episode.episodeNumber ?? 1,
              episodes: latest is VideoPlayerStateLoaded ? latest.episodes : [],
              showEpisodesList: false,
              showAudioPanel: false,
              showSubtitlePanel: false,
              isLoading: false,
              currentAudioIndex: _lastAudioTrack ?? 0,
              currentSubtitleIndex: _lastSubtitleTrack ?? -1,
            ));
          }
        } catch (e) {
          // En caso de error, mantener el estado actual pero sin loading
          final latestState = state;
          if (latestState is VideoPlayerStateLoaded) {
            emit(latestState.copyWith(
              isLoading: false,
              status: VideoPlayerStatus.loaded,
            ));
          }
          emit(VideoPlayerState.error('Error cambiando episodio: $e'));
        }
      }
    });

    // Evento: toggle lista de episodios
    on<_VideoPlayerEventToggleEpisodesList>((event, emit) {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded) {
        emit(currentState.copyWith(
          showEpisodesList: !currentState.showEpisodesList,
        ));
      }
    });

    // Evento: cargar pistas de audio
    on<_VideoPlayerEventLoadAudioTracks>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        emit(currentState.copyWith(status: VideoPlayerStatus.loadingAudio));
        try {
          final audioTracks = await controller!.getAudioTracks();
          int? audioSelected = currentState.currentAudioIndex;
          int audioSelectedId = audioSelected;

          final trackOptions = audioTracks.entries.map((entry) {
            return TrackOptionModel(
              key: entry.key,
              value: entry.value,
            );
          }).toList();
          emit(currentState.copyWith(audioTracks: trackOptions, currentAudioIndex: audioSelectedId, showAudioPanel: true, showSubtitlePanel: false, status: VideoPlayerStatus.loadedAudio));
        } catch (e) {
          // Error al cargar pistas de audio
        }
      }
    });

    // Evento: cargar pistas de subtítulos
    on<_VideoPlayerEventLoadSubtitleTracks>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        emit(currentState.copyWith(status: VideoPlayerStatus.loadingSubtitles));
        try {
          final subtitleTracks = await controller!.getSpuTracks();
          int? subtitleSelected = currentState.currentSubtitleIndex;
          int subtitleSelectedId = subtitleSelected;

          final trackOptions = <TrackOptionModel>[
            // Agregar opción para desactivar subtítulos
            TrackOptionModel(
              key: -1,
              value: 'Sin subtítulos',
            ),
            // Agregar las pistas de subtítulos disponibles
            ...subtitleTracks.entries.map((entry) {
              return TrackOptionModel(
                key: entry.key,
                value: entry.value,
              );
            }),
          ];

          emit(currentState.copyWith(subtitles: trackOptions, currentSubtitleIndex: subtitleSelectedId, showSubtitlePanel: true, showAudioPanel: false, status: VideoPlayerStatus.loadedSubtitles));
        } catch (e) {
          // Error al cargar subtítulos
        }
      }
    });

    // Evento: cambiar pista de audio
    on<_VideoPlayerEventChangeAudioTrack>((event, emit) async {
      // Guardar preferencia siempre
      _lastAudioTrack = event.trackId;

      final currentState = state;
      if (controller != null) {
        try {
          // Intentar aplicar inmediatamente (si funciona mejor), si no, _applyPreferredTracks se encargará
          await controller!.setAudioTrack(event.trackId);
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentAudioIndex: event.trackId));
          }
          return;
        } catch (_) {
          // si falla, continuamos: la preferencia quedó guardada y será aplicada por _applyPreferredTracks
        }
      }
    });

    // Evento: cambiar pista de subtítulos
    on<_VideoPlayerEventChangeSubtitleTrack>((event, emit) async {
      _lastSubtitleTrack = event.trackId;
      final currentState = state;
      if (controller != null) {
        try {
          if (event.trackId == -1) {
            await controller!.setSpuTrack(-1);
          } else {
            await controller!.setSpuTrack(event.trackId);
          }
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentSubtitleIndex: event.trackId));
          }
          return;
        } catch (_) {
          // dejar guardada la preferencia para reintento
        }
      }
    });

    // Evento: cambiar posición
    on<_VideoPlayerEventSeekTo>((event, emit) async {
      if (controller != null) {
        try {
          // Para seeking directo (slider), actualizar inmediatamente y ejecutar
          final currentState = state;
          if (currentState is VideoPlayerStateLoaded) {
            // Actualizar visualmente de inmediato
            emit(currentState.copyWith(currentPosition: event.position));

            // Ejecutar seeking directo para slider (móvil)
            await controller!.seekTo(event.position);
          }
        } catch (e) {
          // Error al cambiar posición
        }
      }
    });
    // Evento pausa:
    on<_VideoPlayerEventPause>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        try {
          await controller!.pause();
          emit(currentState.copyWith(isPlaying: false));
        } catch (e) {
          // Error al pausar
        }
      }
    });
    // Evento reanudar:
    on<_VideoPlayerEventPlay>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        try {
          await controller!.play();
          emit(currentState.copyWith(isPlaying: true));
        } catch (e) {
          // Error al reanudar
        }
      }
    });
    // evento reiniciar video
    on<_VideoPlayerEventRestart>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        try {
          // Guardar las pistas actuales antes de reiniciar
          _saveCurrentTracks();

          if (!currentState.hasEnded) {
            await controller!.seekTo(Duration.zero);
            await controller!.play();
            await _applyPreferredTracks();
            emit(currentState.copyWith(
              hasEnded: false,
              isPlaying: true,
              currentPosition: Duration.zero,
              currentAudioIndex: _lastAudioTrack ?? currentState.currentAudioIndex,
              currentSubtitleIndex: _lastSubtitleTrack ?? currentState.currentSubtitleIndex,
            ));
            return;
          }

          await controller!.stop(); // detener limpio
          await Future.delayed(const Duration(milliseconds: 300)); // darle tiempo
          await controller!.play();
          emit(currentState.copyWith(
            hasEnded: false,
            isPlaying: true,
            currentPosition: Duration.zero,
            currentAudioIndex: _lastAudioTrack ?? currentState.currentAudioIndex,
            currentSubtitleIndex: _lastSubtitleTrack ?? currentState.currentSubtitleIndex,
          ));

          // Restaurar las pistas después de reiniciar
          await _applyPreferredTracks();
        } catch (e) {
          // Error al reiniciar
        }
      }
    });

    on<_VideoPlayerEventEnded>((event, emit) {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded) {
        emit(currentState.copyWith(
          hasEnded: true,
          isPlaying: false,
        ));
      }
    });

    on<_VideoPlayerEventSkipForward>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        final newPosition = currentState.currentPosition + Duration(seconds: event.seconds);
        final maxPosition = currentState.duration;
        final targetPosition = newPosition > maxPosition ? maxPosition : newPosition;

        // Actualizar visualmente de inmediato
        emit(currentState.copyWith(currentPosition: targetPosition));

        // Acumular seeking para TV
        _handleAccumulatedSeek(targetPosition);
      }
    });
    on<_VideoPlayerEventSkipBackward>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        final newPosition = currentState.currentPosition - Duration(seconds: event.seconds);
        final targetPosition = newPosition.isNegative ? Duration.zero : newPosition;

        // Actualizar visualmente de inmediato
        emit(currentState.copyWith(currentPosition: targetPosition));

        // Acumular seeking para TV
        _handleAccumulatedSeek(targetPosition);
      }
    });

    on<_VideoPlayerEventTogglePlayPause>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        if (currentState.hasEnded) {
          await controller!.stop(); // detener limpio
          await Future.delayed(const Duration(milliseconds: 300)); // darle tiempo
          await controller!.play();
          emit(currentState.copyWith(
            hasEnded: false,
            isPlaying: true,
            currentPosition: Duration.zero,
          ));
        } else if (currentState.isPlaying) {
          await controller!.pause();
          emit(currentState.copyWith(isPlaying: false));
        } else {
          await controller!.play();
          emit(currentState.copyWith(isPlaying: true));
        }
      }
    });

    // Handlers para eventos de conectividad
    on<_VideoPlayerEventConnectionLost>((event, emit) {
      _handleConnectionLost();
    });

    on<_VideoPlayerEventConnectionRestored>((event, emit) {
      _handleConnectionRestored();
    });

    on<_VideoPlayerEventRetryConnection>((event, emit) {
      _retryConnection();
    });

    on<_VideoPlayerEventCheckConnectivity>((event, emit) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult.any((result) => result != ConnectivityResult.none);
      _hasConnectivity = hasConnection;

      final currentState = state;
      if (currentState is VideoPlayerStateLoaded) {
        emit(currentState.copyWith(hasConnectivity: hasConnection));
      }
    });
  }

  void _setupPositionListeners() {
    // Cancelar listeners anteriores

    if (controller != null) {
      // Usar el patrón oficial de VLC con addListener (más eficiente)
      controller!.addListener(_onVlcPlayerValueChanged);
    }
  }

  void _onVlcPlayerValueChanged() {
    try {
      if (controller != null && controller!.value.isInitialized) {
        if (!_preferredAppliedOnce) {
          _preferredAppliedOnce = true;
          _applyPreferredTracks(timeout: const Duration(seconds: 6));
        }
        final currentState = state;
        if (currentState is VideoPlayerStateLoaded) {
          final position = controller!.value.position;
          final duration = controller!.value.duration;
          final playingState = controller!.value.playingState;

          // Solo actualizar posición si no estamos en proceso de seeking acumulado
          // o si la posición es muy diferente a la acumulada
          bool shouldUpdatePosition = _accumulatedSeekPosition == null;

          if (_accumulatedSeekPosition != null) {
            // Si tenemos seeking acumulado, solo actualizar si la posición actual está cerca de la posición objetivo
            final difference = (position.inMilliseconds - _accumulatedSeekPosition!.inMilliseconds).abs();
            shouldUpdatePosition = difference < 2000; // Tolerancia de 2 segundos para TV
          }

          // Actualizar posición y duración
          if (shouldUpdatePosition && position.inMilliseconds >= 0 && duration.inMilliseconds > 0 && (position != currentState.currentPosition || duration != currentState.duration)) {
            emit(currentState.copyWith(
              currentPosition: position,
              duration: duration,
            ));
          }

          // ✅ Detectar cuando el video terminó con el estado oficial
          if (playingState == PlayingState.ended && !currentState.hasEnded) {
            emit(currentState.copyWith(
              hasEnded: true,
              isPlaying: false,
              currentPosition: duration, // asegurar que quede al final
            ));
          }

          // ✅ Detectar errores de VLC (cuando no puede reproducir el video)
          if (playingState == PlayingState.error) {
            emit(VideoPlayerState.error(' No se puede reproducir el video. Verifique la URL o su conexión a internet.'));
          }
          if (playingState == PlayingState.playing && !_postPlayApplied) {
            _postPlayApplied = true;
            try {
              if (_lastAudioTrack != null && _lastAudioTrack! >= 0) {
                controller!.setAudioTrack(_lastAudioTrack!);
              }
              if (_lastSubtitleTrack != null) {
                controller!.setSpuTrack(_lastSubtitleTrack!);
              }
            } catch (_) {}
          }
        }
      } else if (controller != null && !controller!.value.isInitialized) {
        // Si el controlador existe pero no se inicializó después de un tiempo, es probable que haya un error
        final currentState = state;
        if (currentState is VideoPlayerStateLoaded) {
          // Dar tiempo para la inicialización antes de marcar como error
          Future.delayed(const Duration(seconds: 10), () {
            if (controller != null && !controller!.value.isInitialized && state is VideoPlayerStateLoaded) {
              emit(VideoPlayerState.error('El video no se pudo cargar. Verifique la URL o su conexión a internet.'));
            }
          });
        }
      }
    } catch (e) {
      // Si hay errores críticos en el listener, emitir estado de error
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded) {
        emit(VideoPlayerState.error('Error crítico del reproductor: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() async {
    // Limpiar listeners y recursos
    if (controller != null) {
      controller!.removeListener(_onVlcPlayerValueChanged);
    }

    // Cancelar suscripción de conectividad
    await _connectivitySubscription?.cancel();

    // Cancelar timer de seeking
    _seekingTimer?.cancel();

    // Limpiar controlador
    try {
      if (controller != null && controller!.value.isInitialized) {
        await controller!.stop();
      }
      await controller?.dispose();
    } catch (e) {}
    return super.close();
  }

  // Métodos para manejo de conectividad
  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final hasConnection = results.any((result) => result != ConnectivityResult.none);

        if (_hasConnectivity != hasConnection) {
          _hasConnectivity = hasConnection;

          if (!hasConnection) {
            // Perdió conectividad
            add(const VideoPlayerEvent.connectionLost());
          } else {
            // Recuperó conectividad
            add(const VideoPlayerEvent.connectionRestored());
          }
        }
      },
    );
  }

  void _handleConnectionLost() {
    final currentState = state;
    if (currentState is VideoPlayerStateLoaded) {
      _lastPosition = currentState.currentPosition;

      emit(VideoPlayerState.connectionLost(
        lastVideoUrl: _lastVideoUrl ?? '',
        lastEpisodeNum: _lastEpisodeNum ?? 1,
        lastPosition: _lastPosition ?? Duration.zero,
      ));
    }
  }

  void _handleConnectionRestored() {
    final currentState = state;
    if (currentState is VideoPlayerStateConnectionLost) {
      // Intentar reconectar automáticamente
      add(VideoPlayerEvent.retryConnection());
    }
  }

  void _retryConnection() async {
    if (_lastVideoUrl != null && _lastEpisodeNum != null) {
      emit(VideoPlayerState.reconnecting(
        videoUrl: _lastVideoUrl!,
        episodeNum: _lastEpisodeNum!,
        lastPosition: _lastPosition ?? Duration.zero,
      ));

      // Intentar cargar el video nuevamente
      add(VideoPlayerEvent.loadedVideo(
        videoUrl: _lastVideoUrl!,
        episodeNum: _lastEpisodeNum!,
      ));
    }
  }

  // Método helper para guardar las pistas actuales antes de recrear el controlador
  void _saveCurrentTracks() {
    final currentState = state;
    if (currentState is VideoPlayerStateLoaded) {
      _lastAudioTrack = currentState.currentAudioIndex;
      _lastSubtitleTrack = currentState.currentSubtitleIndex;
    }
  }

  // Método para manejar seeking acumulado en TV
  void _handleAccumulatedSeek(Duration targetPosition) {
    _accumulatedSeekPosition = targetPosition;
    _seekCount++;

    // Cancelar timer anterior
    _seekingTimer?.cancel();

    // Establecer nuevo timer para ejecutar el seek después de un breve delay
    _seekingTimer = Timer(const Duration(milliseconds: 300), () async {
      if (_accumulatedSeekPosition != null && controller != null) {
        try {
          await controller!.seekTo(_accumulatedSeekPosition!);
        } catch (e) {
          // Error en seeking
        }
        _accumulatedSeekPosition = null;
        _seekCount = 0;
      }
    });
  }

  // Helper: encontrar pista en español priorizando "Español" normal sobre "Español Europeo".
  int? _findPreferredSpanishTrack(Map<int, String> tracks) {
    int? bestKey;
    int bestScore = -1;

    String norm(String s) {
      final t = s.toLowerCase();
      return t
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ä', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('è', 'e')
          .replaceAll('ë', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ì', 'i')
          .replaceAll('ï', 'i')
          .replaceAll('î', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ò', 'o')
          .replaceAll('ö', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ù', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('û', 'u');
    }

    bool containsAny(String s, List<String> terms) {
      for (final t in terms) {
        if (s.contains(t)) return true;
      }
      return false;
    }

    bool isSpanishLabel(String s) {
      final n = norm(s);
      return containsAny(n, [
        'spanish',
        'espanol',
        'castellano',
        ' spa',
        'spa ',
        '(spa)',
        '[spa]',
        'spa-',
        'es-es',
      ]);
    }

    bool isLatAmLabel(String s) {
      final n = norm(s);
      return containsAny(n, [
        'latino',
        'latam',
        'es-419',
        'mexico',
        'mx',
        'argentina',
        'ar',
        'peru',
        'pe',
        'chile',
        'cl',
        'colombia',
        'co',
      ]);
    }

    bool isEuropeLabel(String s) {
      final n = norm(s);
      return containsAny(n, [
        'europeo',
        'europe',
        'europa',
        'spain',
        'es-es',
        'castellano',
      ]);
    }

    for (final e in tracks.entries) {
      final label = e.value;
      if (!isSpanishLabel(label)) continue;
      int score = 2;
      if (isLatAmLabel(label)) score = 3;
      if (isEuropeLabel(label)) score = score == 3 ? 3 : 1;
      if (score > bestScore) {
        bestScore = score;
        bestKey = e.key;
      }
    }

    return bestKey;
  }

// Método para aplicar pistas preferidas después de cargar video:
  Future<void> _applyPreferredTracks({Duration timeout = const Duration(seconds: 4)}) async {
    if (controller == null) return;

    final start = DateTime.now();

    // Esperar a que el controller esté inicializado (timeout)
    while (!controller!.value.isInitialized) {
      if (DateTime.now().difference(start) > timeout) break;
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Intenta recuperar y aplicar pista de audio si existe
    bool audioSet = false;
    if (_lastAudioTrack != null && _lastAudioTrack! >= 0) {
      final audioStart = DateTime.now();
      bool applied = false;

      while (!applied && DateTime.now().difference(audioStart) <= timeout) {
        try {
          final audioTracks = await controller!.getAudioTracks();
          if (audioTracks.containsKey(_lastAudioTrack)) {
            await controller!.setAudioTrack(_lastAudioTrack!);
            // Emitir estado actualizado si estamos en loaded
            final currentState = state;
            if (currentState is VideoPlayerStateLoaded) {
              emit(currentState.copyWith(currentAudioIndex: _lastAudioTrack ?? 0));
            }
            applied = true;
            break;
          }
        } catch (_) {
          // ignorar y reintentar
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
      audioSet = applied;
    }

    // Fallback: si no se pudo aplicar la última pista, seleccionar Español por defecto
    if (!audioSet) {
      try {
        Map<int, String> audioTracksAll = {};
        final waitStart = DateTime.now();
        while (audioTracksAll.isEmpty && DateTime.now().difference(waitStart) <= timeout) {
          audioTracksAll = await controller!.getAudioTracks();
          if (audioTracksAll.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
        final preferredAudio = _findPreferredSpanishTrack(audioTracksAll);
        if (preferredAudio != null && preferredAudio >= 0) {
          await controller!.setAudioTrack(preferredAudio);
          final currentState = state;
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentAudioIndex: preferredAudio));
          }
          _lastAudioTrack = preferredAudio;
        }
      } catch (_) {}
    }

    // Intenta recuperar y aplicar pista de subtítulo si existe
    bool subtitleSet = false;
    if (_lastSubtitleTrack != null) {
      final subStart = DateTime.now();
      bool appliedSub = false;

      while (!appliedSub && DateTime.now().difference(subStart) <= timeout) {
        try {
          final spuTracks = await controller!.getSpuTracks();
          if (_lastSubtitleTrack == -1) {
            // opción para desactivar subtítulos
            await controller!.setSpuTrack(-1);
            final currentState = state;
            if (currentState is VideoPlayerStateLoaded) {
              emit(currentState.copyWith(currentSubtitleIndex: -1));
            }
            appliedSub = true;
            break;
          } else if (spuTracks.containsKey(_lastSubtitleTrack)) {
            await controller!.setSpuTrack(_lastSubtitleTrack!);
            final currentState = state;
            if (currentState is VideoPlayerStateLoaded) {
              emit(currentState.copyWith(currentSubtitleIndex: _lastSubtitleTrack ?? 0));
            }
            appliedSub = true;
            break;
          }
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 200));
      }
      subtitleSet = appliedSub;
    }

    // Fallback: si no hay preferencia previa o no se pudo aplicar, seleccionar subtítulo en Español por defecto
    if (!subtitleSet) {
      try {
        Map<int, String> spuTracksAll = {};
        final waitStartSub = DateTime.now();
        while (spuTracksAll.isEmpty && DateTime.now().difference(waitStartSub) <= timeout) {
          spuTracksAll = await controller!.getSpuTracks();
          if (spuTracksAll.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
        final preferredSub = _findPreferredSpanishTrack(spuTracksAll);
        if (preferredSub != null) {
          await controller!.setSpuTrack(preferredSub);
          final currentState = state;
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentSubtitleIndex: preferredSub));
          }
          _lastSubtitleTrack = preferredSub;
        }
      } catch (_) {}
    }
  }
}
