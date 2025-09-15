import 'dart:async';

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

  VideoPlayerBloc() : super(const VideoPlayerState.initial()) {
    // Caché para episodios por seasonId
    final Map<int, List<EpisodeModel>> episodesCache = {};
    // int? currentSeasonId;

    on<VideoPlayerEvent>((event, emit) {});
    on<_VideoPlayerEventLoadedVideo>((event, emit) async {
      await controller?.stop();
      await controller?.dispose();
      controller = VlcPlayerController.network(
        event.videoUrl,
        hwAcc: HwAcc.auto,
        autoPlay: true,
      );

      // Configurar listeners para posición y duración
      _setupPositionListeners();

      emit(
        VideoPlayerState.loaded(
          status: VideoPlayerStatus.inicialiced,
          videoUrl: event.videoUrl,
          controller: controller!,
          episodeIndex: event.episodeNum,
          showAudioPanel: false,
          showSubtitlePanel: false,
          isPlaying: true,
        ),
      );
    });

    // Evento: cargar episodios
    on<_VideoPlayerEventLoadEpisodes>((event, emit) async {
      //  emit(const VideoPlayerState.loading());
      final currentState = state;
      print('📋 Cargando episodios para seasonId: ${event.seasonId}');
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

          print('📋 Episodios obtenidos desde caché para seasonId: ${event.seasonId}');

          emit(currentState.copyWith(
            episodes: episodes,
            showEpisodesList: episodes.isNotEmpty, // Mostrar lista si hay episodios
            status: VideoPlayerStatus.loadedEpisodes,
          ));
        }
      } catch (e) {
        print('❌ Error cargando episodios para seasonId: ${event.seasonId} - Error: $e');
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
        emit(currentState.copyWith(
          isLoading: true,
          showEpisodesList: false, // Cerrar la lista al cambiar episodio
          episodeIndex: event.episode.episodeNumber ?? 1,
        ));
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
                advanced: VlcAdvancedOptions(['--network-caching=2000']),
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
              showEpisodesList: false,
              showAudioPanel: false,
              showSubtitlePanel: false,
              isLoading: false,
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
            ));
          }
        } catch (e) {
          // En caso de error, mantener el estado actual pero sin loading
          final latestState = state;
          if (latestState is VideoPlayerStateLoaded) {
            emit(latestState.copyWith(
              isLoading: false,
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
          int? audioSelected = await controller!.getAudioTrack();

          int audioSelectedIndex = audioSelected ?? 0;
          final trackOptions = audioTracks.entries.map((entry) {
            return TrackOptionModel(
              key: entry.key,
              value: entry.value,
            );
          }).toList();
          emit(currentState.copyWith(audioTracks: trackOptions, currentAudioIndex: audioSelectedIndex, showAudioPanel: true, showSubtitlePanel: false, status: VideoPlayerStatus.loadedAudio));
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
          int? subtitleSelected = await controller!.getSpuTrack();
          int subtitleSelectedIndex = subtitleSelected ?? 0;
          final trackOptions = subtitleTracks.entries.map((entry) {
            return TrackOptionModel(
              key: entry.key,
              value: entry.value,
            );
          }).toList();

          emit(currentState.copyWith(subtitles: trackOptions, currentSubtitleIndex: subtitleSelectedIndex, showSubtitlePanel: true, showAudioPanel: false, status: VideoPlayerStatus.loadedSubtitles));
        } catch (e) {
          // Error al cargar subtítulos
        }
      }
    });

    // Evento: cambiar pista de audio
    on<_VideoPlayerEventChangeAudioTrack>((event, emit) async {
      final currentState = state;
      if (controller != null) {
        try {
          await controller!.setAudioTrack(event.trackId);
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentAudioIndex: event.trackId));
          }
        } catch (e) {
          // Error al cambiar pista de audio
        }
      }
    });

    // Evento: cambiar pista de subtítulos
    on<_VideoPlayerEventChangeSubtitleTrack>((event, emit) async {
      final currentState = state;
      if (controller != null) {
        try {
          await controller!.setSpuTrack(event.trackId);
          if (currentState is VideoPlayerStateLoaded) {
            emit(currentState.copyWith(currentSubtitleIndex: event.trackId));
          }
        } catch (e) {
          // Error al cambiar subtítulos
        }
      }
    });

    // Evento: cambiar posición
    on<_VideoPlayerEventSeekTo>((event, emit) async {
      if (controller != null) {
        try {
          await controller!.seekTo(event.position);
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
          await controller!.stop(); // detener limpio
          await Future.delayed(const Duration(milliseconds: 300)); // darle tiempo
          await controller!.play();
          emit(currentState.copyWith(
            hasEnded: false,
            isPlaying: true,
            currentPosition: Duration.zero,
          ));
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
        await controller?.seekTo(targetPosition);
      }
    });
    on<_VideoPlayerEventSkipBackward>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        final newPosition = currentState.currentPosition - Duration(seconds: event.seconds);
        final maxPosition = currentState.duration;
        final targetPosition = newPosition > maxPosition ? maxPosition : newPosition;
        await controller?.seekTo(targetPosition);
      }
    });
    on<_VideoPlayerEventTogglePlayPause>((event, emit) async {
      final currentState = state;
      if (currentState is VideoPlayerStateLoaded && controller != null) {
        if (currentState.isPlaying) {
          await controller!.pause();
          emit(currentState.copyWith(isPlaying: false));
        } else {
          await controller!.play();
          emit(currentState.copyWith(isPlaying: true));
        }
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
        final currentState = state;
        if (currentState is VideoPlayerStateLoaded) {
          final position = controller!.value.position;
          final duration = controller!.value.duration;
          final playingState = controller!.value.playingState;

          // Actualizar posición y duración
          if (position.inMilliseconds >= 0 && duration.inMilliseconds > 0 && (position != currentState.currentPosition || duration != currentState.duration)) {
            emit(currentState.copyWith(
              currentPosition: position,
              duration: duration,
            ));
          }

          // ✅ Detectar cuando el video terminó con el estado oficial
          if (playingState == PlayingState.ended && !currentState.hasEnded) {
            print('🎬 El video terminó');
            emit(currentState.copyWith(
              hasEnded: true,
              isPlaying: false,
              currentPosition: duration, // asegurar que quede al final
            ));
          }
        }
      }
    } catch (e) {
      // Ignorar errores de posición para evitar spam en logs
    }
  }

  @override
  Future<void> close() async {
    // Limpiar listeners y recursos
    if (controller != null) {
      controller!.removeListener(_onVlcPlayerValueChanged);
    }
    // Limpiar controlador

    await controller?.stop();
    await controller?.dispose();
    return super.close();
  }
}
