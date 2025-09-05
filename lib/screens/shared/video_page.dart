import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/dtos/response/episode_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player/video_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/video_controls_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/option_panel.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class VideoPageWrapper extends StatelessWidget {
  const VideoPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoPage();
  }
}

class _VideoPageState extends State<VideoPage> {
  String videoUrl = '';
  int videoId = 0;
  int? seasonId;
  int? episodeNumber;
  String? type;
  final bool isTV = PlatformUtils.isTV;
  String deviceId = "";
  VideoControlsManager? _controlsManager;
  late VideoPlayerBloc _videoPlayerBloc;
  bool showSubtitlePanel = false;
  bool showAudioPanel = false;
  bool showQualityPanel = false;
  bool showEpisodePanel = false;

  final FocusNode _focusNode = FocusNode();

  // TV Focus System
  int _currentFocusIndex = 0; // 0: play/pause, 1: slider, 2: restart, 3: audio, 4: subtitles, 5: episodes (series only), 6: settings
  int get _maxFocusIndex => type == 'series' ? 6 : 5;

  // Referencias a los paneles para navegación
  final GlobalKey<OptionPanelState> _subtitlePanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _audioPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _qualityPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _episodePanelKey = GlobalKey<OptionPanelState>();

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
    _videoPlayerBloc = instance<VideoPlayerBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as VideoPageArguments;
      videoUrl = args.videoUrl;
      videoId = args.videoId;
      seasonId = args.seasonId;
      episodeNumber = args.episodeNumber;
      type = args.type;

      // Los episodios se manejarán con lista estática temporal
      // TODO: Implementar llamada al bloc para obtener episodios usando seasonId

      // Inicializar el video player con VideoPlayerBloc
      _videoPlayerBloc.add(VideoPlayerEvent.initialize(videoUrl: 'https://scroll-tv-movie-home-cdn.b-cdn.net/Pantera%20Negra.mp4'));

      _focusNode.requestFocus();
    });

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
          // Cerrar todos los paneles cuando los controles se oculten automáticamente
          setState(() {
            showSubtitlePanel = false;
            showAudioPanel = false;
            showQualityPanel = false;
            showEpisodePanel = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerBloc.add(const VideoPlayerEvent.dispose());
    _controlsManager?.dispose();
    _focusNode.dispose();
    if (!isTV) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
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
    // Cargar episodios desde el bloc si es una serie y tenemos seasonId
    if (type == 'series' && seasonId != null) {
      _videoPlayerBloc.add(VideoPlayerEvent.loadEpisodes(seasonId: seasonId!));
    }
    
    setState(() {
      showEpisodePanel = true;
      showSubtitlePanel = false;
      showAudioPanel = false;
      showQualityPanel = false;
    });
    // Reiniciar timer cuando se abre un panel
    _controlsManager?.resetTimer();
  }

  void _hideEpisodePanel() {
    setState(() {
      showEpisodePanel = false;
    });
  }

  // Helper methods to get dynamic options
  List<Map<String, String>> _getSubtitleOptions(VideoPlayerState state) {
    if (state.subtitleTracks.isNotEmpty) {
      return state.subtitleTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return {'label': track['name'] ?? 'Subtítulo ${index + 1}', 'value': index.toString()};
      }).toList();
    }

    return [
      {'label': 'No hay más subtítulos por el momento.', 'value': '0'}
    ];
  }

  List<Map<String, String>> _getAudioOptions(VideoPlayerState state) {
    if (state.audioTracks.isNotEmpty) {
      return state.audioTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return {'label': track['name'] ?? 'Audio ${index + 1}', 'value': index.toString()};
      }).toList();
    }

    return [
      {'label': 'No hay más audio por el momento.', 'value': '0'}
    ];
  }

  List<Map<String, String>> _getQualityOptions() {
    // Solo mostrar opción automática - funcionalidad de calidad eliminada
    return [
      {'label': 'Automática', 'value': '0'}
    ];
  }

  List<Map<String, String>> _getEpisodeOptions() {
    // Obtener episodios del estado del bloc
    final blocEpisodes = _videoPlayerBloc.state.episodes;
    
    if (blocEpisodes.isNotEmpty) {
      return blocEpisodes.map<Map<String, String>>((episode) {
        final episodeMap = episode as Map<String, dynamic>;
        return {
          'label': 'Ep ${episodeMap['episodeNumber']}: ${episodeMap['title']}',
          'value': episodeMap['episodeNumber'].toString()
        };
      }).toList();
    }
    
    // Si no hay episodios en el bloc y es una serie, mostrar mensaje de carga
    if (type == 'series') {
      return [
        {'label': 'Cargando episodios...', 'value': '0'}
      ];
    }
    
    return [
      {'label': 'No hay episodios disponibles', 'value': '1'}
    ];
  }

  void _selectEpisode(String episodeNum) {
    // Obtener episodios del estado del bloc
    final blocEpisodes = _videoPlayerBloc.state.episodes;
    
    if (blocEpisodes.isNotEmpty && episodeNum != '0') {
      final selectedEpisodeData = blocEpisodes.firstWhere(
        (episode) {
          final episodeMap = episode as Map<String, dynamic>;
          return episodeMap['episodeNumber'].toString() == episodeNum;
        },
        orElse: () => blocEpisodes.first,
      ) as Map<String, dynamic>;

      _videoPlayerBloc.add(VideoPlayerEvent.initialize(
        videoUrl: selectedEpisodeData['videoUrl'],
      ));

      setState(() {
        episodeNumber = selectedEpisodeData['episodeNumber'];
        videoId = selectedEpisodeData['id'] ?? 0;
      });
    }

    // Cerrar el panel
    _hideEpisodePanel();
  }

  Widget _buildVideoPlayer(VideoPlayerState state) {
    return state.when(
      initial: () => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
      loading: (url) => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
      ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle, episodes) => Center(
        child: VlcPlayer(
          controller: controller,
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
      error: (message) => Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Error: $message',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  // Método para delegar eventos de teclado a los paneles activos
  void _delegateKeyEventToPanels(KeyEvent event) {
    if (showSubtitlePanel) {
      _subtitlePanelKey.currentState?.handleKeyEvent(event);
    } else if (showAudioPanel) {
      _audioPanelKey.currentState?.handleKeyEvent(event);
    } else if (showQualityPanel) {
      _qualityPanelKey.currentState?.handleKeyEvent(event);
    } else if (showEpisodePanel) {
      _episodePanelKey.currentState?.handleKeyEvent(event);
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
              // En paneles, no hacer nada con derecha
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else if (_isSliderFocused) {
              // Control del slider: +10 segundos
              _videoPlayerBloc.add(const VideoPlayerEvent.skipForward(seconds: 10));
              _controlsManager?.resetTimer();
            } else {
              // Navegar a la derecha entre controles
              setState(() {
                _currentFocusIndex = (_currentFocusIndex + 1) % (_maxFocusIndex + 1);
              });
              _controlsManager?.resetTimer();
            }
          } else {
            if (!showSubtitlePanel) {
              _showSubtitlePanel();
            }
          }
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
              // Salir de paneles con flecha izquierda
              _hideSubtitlePanel();
              _hideAudioPanel();
              _hideQualityPanel();
              _hideEpisodePanel();
              _controlsManager?.resetTimer();
            } else if (_controlsManager!.showControls && _isSliderFocused) {
              // Control del slider: -10 segundos
              _videoPlayerBloc.add(const VideoPlayerEvent.skipBackward(seconds: 10));
              _controlsManager?.resetTimer();
            } else if (_controlsManager!.showControls) {
              // Navegar a la izquierda entre controles
              setState(() {
                _currentFocusIndex = _currentFocusIndex == 0 ? _maxFocusIndex : _currentFocusIndex - 1;
              });
              _controlsManager?.resetTimer();
            } else {
              Navigator.pop(context);
            }
          } else {
            if (showSubtitlePanel) {
              _hideSubtitlePanel();
            }
            _hideAudioPanel();
            _hideQualityPanel();
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
              _controlsManager?.resetTimer();
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Navegar hacia arriba: de botones inferiores a slider o play/pause
              setState(() {
                if (_currentFocusIndex >= 2) {
                  _currentFocusIndex = 1; // Ir al slider
                } else if (_currentFocusIndex == 1) {
                  _currentFocusIndex = 0; // Ir al play/pause
                }
              });
              _controlsManager?.resetTimer();
            }
          }
          break;
        case LogicalKeyboardKey.arrowDown:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
              _controlsManager?.resetTimer();
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Navegar hacia abajo: de play/pause a slider, de slider a botones
              setState(() {
                if (_currentFocusIndex == 0) {
                  _currentFocusIndex = 1; // Ir al slider
                } else if (_currentFocusIndex == 1) {
                  _currentFocusIndex = 2; // Ir a los botones (restart)
                }
              });
              _controlsManager?.resetTimer();
            }
          }
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
              _controlsManager?.resetTimer();
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Activar el elemento con focus
              switch (_currentFocusIndex) {
                case 0: // Play/Pause
                  _videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
                  break;
                case 1: // Slider - no hacer nada en select
                  break;
                case 2: // Episodes (series only) or Restart (movies)
                  if (type == 'series') {
                    _showEpisodePanel();
                  } else {
                    _videoPlayerBloc.add(const VideoPlayerEvent.restart());
                  }
                  break;
                case 3: // Restart (series) or Audio (movies)
                  if (type == 'series') {
                    _videoPlayerBloc.add(const VideoPlayerEvent.restart());
                  } else {
                    _showAudioPanel();
                  }
                  break;
                case 4: // Audio (series) or Subtitles (movies)
                  if (type == 'series') {
                    _showAudioPanel();
                  } else {
                    _showSubtitlePanel();
                  }
                  break;
                case 5: // Subtitles (series) or Settings (movies)
                  if (type == 'series') {
                    _showSubtitlePanel();
                  } else {
                    _showQualityPanel();
                  }
                  break;
                case 6: // Settings (series only)
                  if (type == 'series') {
                    _showQualityPanel();
                  }
                  break;
              }
              _controlsManager?.resetTimer();
            }
          }
          break;
        case LogicalKeyboardKey.space:
          // Play/Pause para ambas plataformas
          _videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
          _controlsManager?.resetTimer();
          break;
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.goBack:
          if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
            _hideSubtitlePanel();
            _hideAudioPanel();
            _hideQualityPanel();
            _hideEpisodePanel();
            _controlsManager?.resetTimer();
          } else {
            // Limpiar recursos del video player antes de navegar
            _videoPlayerBloc.add(const VideoPlayerEvent.dispose());
            _controlsManager?.dispose();

            if (Navigator.canPop(context)) {
              print('There is a previous page to return to');
              Navigator.pop(context);
            } else {
              print('No previous page available');
              Navigator.pushReplacementNamed(context, Routes.homeRoute);
            }
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      bloc: _videoPlayerBloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: Stack(
              children: [
                // Video Player
                _buildVideoPlayer(state),

                // Controls Overlay
                if (_controlsManager?.showControls == true)
                  Stack(
                    children: [
                      // Background tap to hide controls
                      GestureDetector(
                        onTap: () {
                          _controlsManager?.hideControls();
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      // Controls that don't hide when tapped
                      GestureDetector(
                        onTap: () {
                          _controlsManager?.resetTimer();
                        }, // Prevent tap from propagating
                        child: Column(
                          children: [
                            // Top Bar
                            SafeArea(
                              child: Padding(
                                padding: EdgeInsets.all(isTV ? 24 : 16),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: isTV ? 36 : 28),
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
                                      // Play/Pause Button (Left)
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
                                              _videoPlayerBloc.add(const VideoPlayerEvent.restart());
                                            } else {
                                              _videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
                                            }
                                            _controlsManager?.resetTimer();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: isTV ? 24 : 16),
                                      // Times
                                      Text(
                                        '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.duration)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTV ? 18 : 14,
                                          fontWeight: isTV ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),

                                  SizedBox(height: isTV ? 16 : 8),

                                  // Progress Bar
                                  Container(
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
                                        trackHeight: isTV ? 6 : 4,
                                        thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: isTV ? 12 : 8,
                                        ),
                                        overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: isTV ? 20 : 16,
                                        ),
                                      ),
                                      child: Slider(
                                        value: state.duration.inMilliseconds > 0 ? state.currentPosition.inMilliseconds / state.duration.inMilliseconds : 0.0,
                                        onChanged: (value) {
                                          if (state.duration.inMilliseconds > 0) {
                                            final position = Duration(
                                              milliseconds: (value * state.duration.inMilliseconds).round(),
                                            );
                                            _videoPlayerBloc.add(VideoPlayerEvent.seekTo(position: position));
                                            _controlsManager?.resetTimer();
                                          }
                                        },
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isTV ? 16 : 8),

                                  // Control Buttons
                                  Row(
                                    mainAxisAlignment: isTV ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
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
                                          child: IconButton(
                                            icon: Icon(Icons.list, color: Colors.white, size: isTV ? 40 : 32),
                                            onPressed: () {
                                              _showEpisodePanel();
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
                                            _videoPlayerBloc.add(const VideoPlayerEvent.restart());
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
                    ],
                  ),

                // Invisible tap area to show controls
                if (_controlsManager?.showControls != true)
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

                // Subtitle Panel
                if (showSubtitlePanel)
                  OptionPanel(
                    key: _subtitlePanelKey,
                    title: 'Subtítulos',
                    isVisible: showSubtitlePanel,
                    currentValue: state.currentSubtitleIndex.toString(),
                    options: _getSubtitleOptions(state),
                    onValueChanged: (String index) {
                      final selectedIndex = int.tryParse(index) ?? 0;
                      _videoPlayerBloc.add(VideoPlayerEvent.changeSubtitleTrack(index: selectedIndex));
                    },
                    onClose: _hideSubtitlePanel,
                  ),

                // Audio Panel
                if (showAudioPanel)
                  OptionPanel(
                    key: _audioPanelKey,
                    title: 'Audio',
                    isVisible: showAudioPanel,
                    currentValue: state.currentAudioIndex.toString(),
                    options: _getAudioOptions(state),
                    onValueChanged: (String index) {
                      final selectedIndex = int.tryParse(index) ?? 0;
                      _videoPlayerBloc.add(VideoPlayerEvent.changeAudioTrack(index: selectedIndex));
                    },
                    onClose: _hideAudioPanel,
                  ),

                // Quality Panel - Solo muestra opción automática
                if (showQualityPanel)
                  OptionPanel(
                    key: _qualityPanelKey,
                    title: 'Calidad',
                    isVisible: showQualityPanel,
                    currentValue: '0', // Siempre automática
                    options: _getQualityOptions(),
                    onValueChanged: (String index) {
                      // No hacer nada - solo hay opción automática
                    },
                    onClose: _hideQualityPanel,
                  ),

                // Episode Panel - Solo para series
                if (showEpisodePanel && type == 'series')
                  OptionPanel(
                    key: _episodePanelKey,
                    title: 'Episodios',
                    isVisible: showEpisodePanel,
                    currentValue: episodeNumber?.toString() ?? '1',
                    options: _getEpisodeOptions(),
                    onValueChanged: (String episodeNum) {
                      _selectEpisode(episodeNum);
                    },
                    onClose: _hideEpisodePanel,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
