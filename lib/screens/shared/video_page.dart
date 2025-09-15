import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/components/video_keyboard_handler.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player/video_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/util_functions.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/video_controls_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/episode_panel.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/option_panel.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  int? initialEpisodeNumber;
  int? seasonId;
  String? type;
  final bool isTV = PlatformUtils.isTV;
  late VideoPlayerBloc bloc;
  String deviceId = "";

  VideoControlsManager? _controlsManager;

  Timer? _episodePanelTimer;

  final FocusNode _focusNode = FocusNode();

  bool showSubtitlePanel = false;
  bool showAudioPanel = false;
  bool showQualityPanel = false;
  bool showEpisodePanel = false;

  int _currentFocusIndex = 0; // 0: play/pause, 1: slider, 2: restart, 3: audio, 4: subtitles, 5: episodes (series only), 6: settings
  int get _maxFocusIndex => type == 'series' ? 6 : 5;

  // Referencias a los paneles para navegación
  final GlobalKey<OptionPanelState> _subtitlePanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _audioPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _qualityPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<EpisodePanelState> _episodePanelKey = GlobalKey<EpisodePanelState>();
  VideoKeyboardHandler? _keyboardHandler;

  // Focus states
  bool get _isPlayPauseFocused => isTV && _currentFocusIndex == 0;
  bool get _isSliderFocused => isTV && _currentFocusIndex == 1;
  bool get _isEpisodesFocused => isTV && type == 'series' && _currentFocusIndex == 2;
  bool get _isRestartFocused => isTV && _currentFocusIndex == (type == 'series' ? 3 : 2);
  bool get _isAudioFocused => isTV && _currentFocusIndex == (type == 'series' ? 4 : 3);
  bool get _isSubtitlesFocused => isTV && _currentFocusIndex == (type == 'series' ? 5 : 4);
  bool get _isSettingsFocused => isTV && _currentFocusIndex == (type == 'series' ? 6 : 5);

  @override
  void initState() {
    super.initState();
    bloc = instance<VideoPlayerBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as VideoPageArguments;
      initialEpisodeNumber = args.episodeNumber;
      seasonId = args.seasonId;
      type = args.type ?? 'movie';
      bloc.add(VideoPlayerEvent.loadedVideo(
        videoUrl: args.videoUrl,
        episodeNum: args.episodeNumber ?? 0,
      ));

      _initializeKeyboardHandler();

      _focusNode.requestFocus();
    });
  }

  void _initializeKeyboardHandler() {
    _keyboardHandler = VideoKeyboardHandler(
      videoPlayerBloc: bloc,
      controlsManager: _controlsManager,
      seasonNum: seasonId ?? 0,
      isTV: isTV,
      type: type,
      currentFocusIndex: _currentFocusIndex,
      showSubtitlePanel: showSubtitlePanel,
      showAudioPanel: showAudioPanel,
      showQualityPanel: showQualityPanel,
      showEpisodePanel: showEpisodePanel,
      subtitlePanelKey: _subtitlePanelKey,
      audioPanelKey: _audioPanelKey,
      qualityPanelKey: _qualityPanelKey,
      episodePanelKey: _episodePanelKey,
      onFocusIndexChanged: (newIndex) {
        setState(() {
          _currentFocusIndex = newIndex;
        });
      },
      onShowSubtitlePanel: _showSubtitlePanel,
      onHideSubtitlePanel: _hideSubtitlePanel,
      onShowAudioPanel: _showAudioPanel,
      onHideAudioPanel: _hideAudioPanel,
      onShowQualityPanel: _showQualityPanel,
      onHideQualityPanel: _hideQualityPanel,
      onShowEpisodePanel: _showEpisodePanel,
      onHideEpisodePanel: _hideEpisodePanel,
      onResetEpisodePanelTimer: _resetEpisodePanelTimer,
      onNavigateBack: () {
        //Navigator.pop(context);  no hacer esto porque hace eso
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isTV) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    PlatformUtils().getDeviceId().then((value) {
      setState(() {
        deviceId = value;
      });
    });

    _initializeControlsManager();
  }

  void _initializeControlsManager() {
    _controlsManager = VideoControlsManager();

    _controlsManager?.initialize(
      onControlsChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      onControlsHidden: () {
        if (mounted) {
          // Solo cerrar paneles si no hay interacción activa
          // El episode panel no se cierra automáticamente para permitir navegación
          setState(() {
            showSubtitlePanel = false;
            showAudioPanel = false;
            showQualityPanel = false;
            // showEpisodePanel se mantiene abierto durante la interacción
          });
        }
      },
    );
  }

  void _showSubtitlePanel() {
    setState(() {
      showSubtitlePanel = true;
      showAudioPanel = false;
      showQualityPanel = false;
      showEpisodePanel = false;
    });
    // Reiniciar timer cuando se abre un panel
    _controlsManager?.resetTimer();
  }

  void _hideSubtitlePanel() {
    setState(() {
      showSubtitlePanel = false;
    });
  }

  void _showAudioPanel() {
    setState(() {
      showAudioPanel = true;
      showSubtitlePanel = false;
      showQualityPanel = false;
      showEpisodePanel = false;
    });
    // Reiniciar timer cuando se abre un panel
    _controlsManager?.resetTimer();
  }

  void _hideAudioPanel() {
    setState(() {
      showAudioPanel = false;
    });
  }

  void _showQualityPanel() {
    setState(() {
      showQualityPanel = true;
      showSubtitlePanel = false;
      showAudioPanel = false;
      showEpisodePanel = false;
    });
    // Reiniciar timer cuando se abre un panel
    _controlsManager?.resetTimer();
  }

  void _hideQualityPanel() {
    setState(() {
      showQualityPanel = false;
    });
  }

  void _showEpisodePanel() {
    // La carga de episodios ahora se maneja automáticamente en _getEpisodeOptions()
    // cuando el EpisodePanel se renderiza, evitando llamadas duplicadas

    setState(() {
      showEpisodePanel = true;
      showSubtitlePanel = false;
      showAudioPanel = false;
      showQualityPanel = false;
    });
    // Reiniciar timer cuando se abre un panel
    _controlsManager?.resetTimer();
    // Iniciar timer específico para el episode panel
    _startEpisodePanelTimer();
  }

  void _hideEpisodePanel() {
    _cancelEpisodePanelTimer();
    setState(() {
      showEpisodePanel = false;
    });
  }

  // Métodos para manejar el timer específico del episode panel
  void _startEpisodePanelTimer() {
    _cancelEpisodePanelTimer();
    _episodePanelTimer = Timer(Duration(seconds: 8), () {
      if (mounted && showEpisodePanel) {
        _hideEpisodePanel();
      }
    });
  }

  void _cancelEpisodePanelTimer() {
    _episodePanelTimer?.cancel();
    _episodePanelTimer = null;
  }

  void _resetEpisodePanelTimer() {
    if (showEpisodePanel) {
      _startEpisodePanelTimer();
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
        bloc: bloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is VideoPlayerStateLoaded) {
            _keyboardHandler?.updateState(
              currentFocusIndex: _currentFocusIndex,
              showSubtitlePanel: showSubtitlePanel,
              showAudioPanel: showAudioPanel,
              showQualityPanel: showQualityPanel,
              showEpisodePanel: showEpisodePanel,
            );
            return KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: _keyboardHandler?.handleKeyEvent,
              child: Stack(
                children: [
                  Center(
                    child: VlcPlayer(
                      controller: state.controller,
                      aspectRatio: 16 / 9,
                      placeholder: Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _controlsManager?.hideControls();
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.5), // inicio
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _controlsManager?.hideControls();
                        },
                        child: Column(
                          children: [
                            SafeArea(
                              child: Padding(
                                padding: EdgeInsets.all(isTV ? 24 : 16),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            //CONTROLS
                            Padding(
                              padding: EdgeInsets.all(isTV ? 32 : 16),
                              child: Column(
                                children: [
                                  // Play/Pause Button and Times Row (above slider)
                                  Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                            border: _isPlayPauseFocused
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              state.hasEnded ? Icons.replay : (state.isPlaying ? Icons.pause : Icons.play_arrow),
                                              color: Colors.white,
                                              size: isTV ? 48 : 32,
                                            ),
                                            onPressed: () async {
                                              if (state.hasEnded) {
                                                bloc.add(VideoPlayerEvent.restart());
                                              }
                                              if (state.controller.value.isPlaying) {
                                                bloc.add(VideoPlayerEvent.pause());
                                              } else {
                                                bloc.add(VideoPlayerEvent.play());
                                              }
                                              _controlsManager?.resetTimer();
                                            },
                                          )),
                                      SizedBox(width: isTV ? 24 : 16),
                                      Text(
                                        '${formatDuration(state.currentPosition)} / ${formatDuration(state.duration)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTV ? 18 : 14,
                                          fontWeight: isTV ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  // Progress Bar
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: _isSliderFocused
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          )
                                        : null,
                                    padding: _isSliderFocused ? EdgeInsets.all(4) : EdgeInsets.zero,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                                        thumbColor: Colors.white,
                                        overlayColor: Colors.white.withOpacity(0.2),
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                      ),
                                      child: Slider(
                                        value: state.duration.inMilliseconds > 0 ? (state.currentPosition.inMilliseconds / state.duration.inMilliseconds).clamp(0.0, 1.0) : 0.0,
                                        onChanged: (value) {
                                          if (state.duration.inMilliseconds > 0) {
                                            final newPosition = Duration(
                                              milliseconds: (value * state.duration.inMilliseconds).round(),
                                            );
                                            bloc.add(VideoPlayerEvent.seekTo(position: newPosition));
                                            _controlsManager?.resetTimer();
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  Row(
                                    mainAxisAlignment: isTV ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Botón de episodios (solo para series) - ahora va primero
                                      if (type == 'series')
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                          decoration: isTV
                                              ? BoxDecoration(
                                                  color: Colors.black.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: _isEpisodesFocused
                                                      ? Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        )
                                                      : null,
                                                )
                                              : null,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.video_collection_outlined, color: Colors.white, size: isTV ? 40 : 32),
                                                onPressed: () {
                                                  _showEpisodePanel();
                                                  _controlsManager?.resetTimer();
                                                },
                                              ),
                                              Text('Episodios', style: TextStyle(color: Colors.white, fontSize: isTV ? 18 : 14)),
                                              SizedBox(width: isTV ? 12 : 8),
                                            ],
                                          ),
                                        ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                        decoration: isTV
                                            ? BoxDecoration(
                                                color: Colors.black.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: _isRestartFocused
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      )
                                                    : null,
                                              )
                                            : null,
                                        child: IconButton(
                                          icon: Icon(Icons.replay, color: Colors.white, size: isTV ? 40 : 32),
                                          onPressed: () async {
                                            bloc.add(const VideoPlayerEvent.restart());
                                            _controlsManager?.resetTimer();
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                        decoration: isTV
                                            ? BoxDecoration(
                                                color: Colors.black.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: _isAudioFocused
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      )
                                                    : null,
                                              )
                                            : null,
                                        child: IconButton(
                                          icon: Icon(Icons.volume_up, color: Colors.white, size: isTV ? 40 : 32),
                                          onPressed: () {
                                            bloc.add(VideoPlayerEvent.loadAudioTracks());
                                            _showAudioPanel();
                                            _controlsManager?.resetTimer();
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                        decoration: isTV
                                            ? BoxDecoration(
                                                color: Colors.black.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: _isSubtitlesFocused
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      )
                                                    : null,
                                              )
                                            : null,
                                        child: IconButton(
                                          icon: Icon(Icons.closed_caption, color: Colors.white, size: isTV ? 40 : 32),
                                          onPressed: () {
                                            bloc.add(VideoPlayerEvent.loadSubtitleTracks());
                                            _showSubtitlePanel();
                                            _controlsManager?.resetTimer();
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                        decoration: isTV
                                            ? BoxDecoration(
                                                color: Colors.black.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: _isSettingsFocused
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      )
                                                    : null,
                                              )
                                            : null,
                                        child: IconButton(
                                          icon: Icon(Icons.settings, color: Colors.white, size: isTV ? 40 : 32),
                                          onPressed: () {
                                            _showQualityPanel();
                                            _controlsManager?.resetTimer();
                                          },
                                        ),
                                      ),
                                      if (!isTV) Spacer()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_controlsManager?.showControls != true && state.controller.value.isBuffering)
                        GestureDetector(
                          onTap: () {
                            _controlsManager?.show();
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                      if (showAudioPanel)
                        OptionPanel(
                          key: _audioPanelKey,
                          title: 'Audio',
                          isVisible: showAudioPanel,
                          // currentValue: state.currentAudioIndex.toString(),
                          //options: state.audioTracks,
                          onValueChanged: (String index) {
                            final selectedIndex = int.tryParse(index) ?? 0;
                            bloc.add(VideoPlayerEvent.changeAudioTrack(trackId: selectedIndex)); //(controller, selectedIndex);
                          },
                          onClose: _hideAudioPanel,
                          videoPlayerBloc: bloc,
                        ),
                      if (showSubtitlePanel)
                        OptionPanel(
                          key: _subtitlePanelKey,
                          title: 'Subtítulos',
                          isVisible: showSubtitlePanel,
                          // currentValue: state.currentSubtitleIndex.toString(),
                          //  options: state.subtitles,
                          onValueChanged: (String index) {
                            final selectedIndex = int.tryParse(index) ?? 0;
                            bloc.add(VideoPlayerEvent.changeSubtitleTrack(trackId: selectedIndex));
                          },
                          onClose: _hideSubtitlePanel,
                          videoPlayerBloc: bloc,
                        ),
                      if (showQualityPanel)
                        OptionPanel(
                          key: _qualityPanelKey,
                          title: 'Calidad',
                          isVisible: showQualityPanel,
                          //  currentValue: '0', // Siempre automática
                          // options: [],
                          onValueChanged: (String index) {
                            // No hacer nada - solo hay opción automática
                          },
                          onClose: _hideQualityPanel,
                          videoPlayerBloc: bloc,
                        ),
                      if (showEpisodePanel && type == 'series')
                        EpisodePanel(
                          key: _episodePanelKey,
                          title: 'Episodios',
                          isVisible: showEpisodePanel,
                          currentValue: state.episodeIndex.toString(),
                          episodes: state.episodes,
                          onValueChanged: (EpisodeModel episode) {
                            bloc.add(
                              VideoPlayerEvent.changeEpisode(episode: episode),
                            );
                          },
                          onClose: _hideEpisodePanel,
                        ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _showAudioTracksDialog(VideoPlayerBloc bloc, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
          bloc: bloc,
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (videoUrl, controller, status, isPlaying, hasEnded, episodes, episodeIndex, showEpisodesList, isLoading, currentPosition, duration, subtitles, audioTracks, showSubtitlePanel,
                  showAudioPanel, selectedSubtitleIndex, selectedAudioIndex, currentSubtitleIndex, currentAudioIndex) {
                final isLoadingTracks = status == VideoPlayerStatus.loadingAudio;

                return AlertDialog(
                  backgroundColor: Colors.black87,
                  title: const Text('Seleccionar Audio', style: TextStyle(color: Colors.white)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: isLoadingTracks
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 16),
                                  Text('Cargando pistas de audio...', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: audioTracks.length,
                            itemBuilder: (context, index) {
                              final track = audioTracks[index];
                              return ListTile(
                                title: Text(track.value, style: const TextStyle(color: Colors.white)),
                                onTap: () {
                                  bloc.add(VideoPlayerEvent.changeAudioTrack(trackId: track.key));
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  // // Método para mostrar diálogo de selección de subtítulos
  // void _showSubtitleTracksDialog(VideoPlayerBloc bloc, BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
  //         bloc: bloc,
  //         builder: (context, state) {
  //           return state.maybeWhen(
  //             loaded: (
  //               videoUrl,
  //               controller,
  //               status,
  //               isPlaying,
  //               hasEnded,
  //               episodes,
  //               episodeIndex,
  //               showEpisodesList,
  //               isLoading,
  //               currentPosition,
  //               duration,
  //               subtitles,
  //               audioTracks,
  //               showSubtitlePanel,
  //               showAudioPanel,
  //               selectedSubtitleIndex,
  //               selectedAudioIndex,
  //             ) {
  //               final isLoadingTracks = status == VideoPlayerStatus.loadingSubtitles;

  //               return AlertDialog(
  //                 backgroundColor: Colors.black87,
  //                 title: const Text('Seleccionar Subtítulos', style: TextStyle(color: Colors.white)),
  //                 content: SizedBox(
  //                   width: double.maxFinite,
  //                   child: isLoadingTracks
  //                       ? const Center(
  //                           child: Padding(
  //                             padding: EdgeInsets.all(20.0),
  //                             child: Column(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 CircularProgressIndicator(color: Colors.white),
  //                                 SizedBox(height: 16),
  //                                 Text('Cargando subtítulos...', style: TextStyle(color: Colors.white)),
  //                               ],
  //                             ),
  //                           ),
  //                         )
  //                       : ListView.builder(
  //                           shrinkWrap: true,
  //                           itemCount: subtitles.length + 1,
  //                           itemBuilder: (context, index) {
  //                             if (index == 0) {
  //                               return ListTile(
  //                                 title: const Text('Sin subtítulos', style: TextStyle(color: Colors.white)),
  //                                 onTap: () {
  //                                   bloc.add(const VideoPlayerEvent.changeSubtitleTrack(trackId: -1));
  //                                   Navigator.of(context).pop();
  //                                 },
  //                               );
  //                             }
  //                             final track = subtitles[index - 1];
  //                             return ListTile(
  //                               title: Text(track.value, style: const TextStyle(color: Colors.white)),
  //                               onTap: () {
  //                                 bloc.add(VideoPlayerEvent.changeSubtitleTrack(trackId: track.key));
  //                                 Navigator.of(context).pop();
  //                               },
  //                             );
  //                           },
  //                         ),
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () => Navigator.of(context).pop(),
  //                     child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ],
  //               );
  //             },
  //             orElse: () => const SizedBox.shrink(),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
