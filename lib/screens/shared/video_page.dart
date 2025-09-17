import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
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

  bool showSubtitlePanel = false;
  bool showAudioPanel = false;
  bool showQualityPanel = false;
  bool showEpisodePanel = false;

  // Timer específico para el episode panel
  Timer? _episodePanelTimer;

  final FocusNode _focusNode = FocusNode();

  // TV Focus System
  int _currentFocusIndex = 0;
  int get _maxFocusIndex => type == 'series' ? 7 : 6;

  // Referencias a los paneles para navegación
  final GlobalKey<OptionPanelState> _subtitlePanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _audioPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _qualityPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<EpisodePanelState> _episodePanelKey = GlobalKey<EpisodePanelState>();

  // Sistema de repetición de teclas
  Timer? _keyRepeatTimer;
  LogicalKeyboardKey? _currentRepeatingKey;
  static const Duration _keyRepeatDelay = Duration(milliseconds: 500); // Delay inicial
  static const Duration _keyRepeatInterval = Duration(milliseconds: 100); // Intervalo de repetición

  // Focus states - Corregidos para evitar inconsistencias
  bool get _isBackFocused => isTV && _currentFocusIndex == 0;
  bool get _isPlayPauseFocused => isTV && _currentFocusIndex == 1;
  bool get _isSliderFocused => isTV && _currentFocusIndex == 2;
  bool get _isEpisodesFocused => isTV && type == 'series' && _currentFocusIndex == 3;
  bool get _isRestartFocused => isTV && _currentFocusIndex == (type == 'series' ? 4 : 3);
  bool get _isAudioFocused => isTV && _currentFocusIndex == (type == 'series' ? 5 : 4);
  bool get _isSubtitlesFocused => isTV && _currentFocusIndex == (type == 'series' ? 6 : 5);
  bool get _isSettingsFocused => isTV && _currentFocusIndex == (type == 'series' ? 7 : 6);

  // Validación de índice de focus para prevenir estados inválidos
  bool get _isValidFocusIndex => _currentFocusIndex >= 0 && _currentFocusIndex <= _maxFocusIndex;

  // Función para validar y corregir el focus si es necesario
  void _validateAndCorrectFocus() {
    if (!_isValidFocusIndex) {
      setState(() {
        _currentFocusIndex = 0; // Resetear a play/pause si hay inconsistencia
      });
    }
  }

  AuthBloc authBloc = instance<AuthBloc>();
  @override
  void initState() {
    authBloc.add(AuthEvent.validateExpiration());
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
      _focusNode.requestFocus();
      _initializeControlsManager();
    });
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
          setState(() {
            showSubtitlePanel = false;
            showAudioPanel = false;
            showQualityPanel = false;
          });
        }
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
  }

  void _showSubtitlePanel() {
    setState(() {
      showSubtitlePanel = true;
      showAudioPanel = false;
      showQualityPanel = false;
      showEpisodePanel = false;
    });
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
    _controlsManager?.resetTimer();
  }

  void _hideQualityPanel() {
    setState(() {
      showQualityPanel = false;
    });
  }

  void _showEpisodePanel() {
    setState(() {
      showEpisodePanel = true;
      showSubtitlePanel = false;
      showAudioPanel = false;
      showQualityPanel = false;
    });
    _controlsManager?.resetTimer();
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
    _controlsManager?.dispose();
    _cancelEpisodePanelTimer();
    _focusNode.dispose();
    if (!isTV) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  bool _delegateKeyEventToPanels(KeyEvent event) {
    if (showSubtitlePanel) {
      return _subtitlePanelKey.currentState?.handleKeyEvent(event) ?? false;
    } else if (showAudioPanel) {
      return _audioPanelKey.currentState?.handleKeyEvent(event) ?? false;
    } else if (showQualityPanel) {
      return _qualityPanelKey.currentState?.handleKeyEvent(event) ?? false;
    } else if (showEpisodePanel) {
      return _episodePanelKey.currentState?.handleKeyEvent(event) ?? false;
    }
    return false;
  }

  // Métodos para manejar repetición de teclas
  void _startKeyRepeat(LogicalKeyboardKey key, VoidCallback action) {
    _stopKeyRepeat();
    _currentRepeatingKey = key;

    // Ejecutar la acción inmediatamente
    action();

    // Iniciar el timer de repetición después del delay inicial
    _keyRepeatTimer = Timer(_keyRepeatDelay, () {
      _keyRepeatTimer = Timer.periodic(_keyRepeatInterval, (timer) {
        action();
      });
    });
  }

  void _stopKeyRepeat() {
    _keyRepeatTimer?.cancel();
    _keyRepeatTimer = null;
    _currentRepeatingKey = null;
  }

  // Método para ejecutar acciones de seek
  void _performSeekAction(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowRight) {
      bloc.add(const VideoPlayerEvent.skipForward(seconds: 10));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      bloc.add(const VideoPlayerEvent.skipBackward(seconds: 10));
    }
    _controlsManager?.resetTimer();
  }

  void _handleKeyEvent(KeyEvent event) {
    // No responder a eventos de teclado si el video está cargando
    final currentState = bloc.state;
    if (currentState is VideoPlayerStateLoaded && currentState.controller.value.isBuffering == true) {
      return;
    }

    // Manejar KeyUpEvent para cancelar repetición
    if (event is KeyUpEvent) {
      if (_currentRepeatingKey == event.logicalKey) {
        _stopKeyRepeat();
      }
      return;
    }

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
              // Control del slider con repetición: +10 segundos
              _startKeyRepeat(event.logicalKey, () => _performSeekAction(event.logicalKey));
            } else {
              setState(() {
                int newIndex = (_currentFocusIndex + 1) % (_maxFocusIndex + 1);
                if (newIndex >= 0 && newIndex <= _maxFocusIndex) {
                  _currentFocusIndex = newIndex;
                } else {
                  _currentFocusIndex = 0;
                }
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
              // Primero delegar al panel activo para navegación interna
              bool eventHandled = _delegateKeyEventToPanels(event);
              if (eventHandled) {
                // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
                _controlsManager?.resetTimer();
                // Si es el episode panel, resetear su timer específico
                if (showEpisodePanel) {
                  _resetEpisodePanelTimer();
                }
              } else {
                // Solo cerrar paneles si no hay navegación interna disponible
                _hideSubtitlePanel();
                _hideAudioPanel();
                _hideQualityPanel();
                _hideEpisodePanel();
                _controlsManager?.resetTimer();
              }
            } else if (_controlsManager!.showControls && _isSliderFocused) {
              // Control del slider con repetición: -10 segundos
              _startKeyRepeat(event.logicalKey, () => _performSeekAction(event.logicalKey));
            } else if (_controlsManager!.showControls) {
              // Navegar a la izquierda entre controles con validación
              setState(() {
                int newIndex = _currentFocusIndex == 0 ? _maxFocusIndex : _currentFocusIndex - 1;
                // Validar que el nuevo índice sea válido
                if (newIndex >= 0 && newIndex <= _maxFocusIndex) {
                  _currentFocusIndex = newIndex;
                } else {
                  // Si hay error, ir al último índice válido
                  _currentFocusIndex = _maxFocusIndex;
                }
              });
              _controlsManager?.resetTimer();
            } else {
              return;
              // Navigator.pop(context);
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
              bool eventHandled = _delegateKeyEventToPanels(event);
              if (eventHandled) {
                // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
                _controlsManager?.resetTimer();
                // Si es el episode panel, resetear su timer específico
                if (showEpisodePanel) {
                  _resetEpisodePanelTimer();
                }
              }
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Navegar hacia arriba: de botones inferiores a slider, play/pause o back
              setState(() {
                int newIndex = _currentFocusIndex;
                if (_currentFocusIndex >= 3) {
                  newIndex = 2; // Ir al slider
                } else if (_currentFocusIndex == 2) {
                  newIndex = 1; // Ir al play/pause
                } else if (_currentFocusIndex == 1) {
                  newIndex = 0; // Ir al back button
                }
                // Validar el nuevo índice antes de asignarlo
                if (newIndex >= 0 && newIndex <= _maxFocusIndex) {
                  _currentFocusIndex = newIndex;
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
              bool eventHandled = _delegateKeyEventToPanels(event);
              if (eventHandled) {
                // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
                _controlsManager?.resetTimer();
                // Si es el episode panel, resetear su timer específico
                if (showEpisodePanel) {
                  _resetEpisodePanelTimer();
                }
              }
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Navegar hacia abajo: de back a play/pause, de play/pause a slider, de slider a botones
              setState(() {
                int newIndex = _currentFocusIndex;
                if (_currentFocusIndex == 0) {
                  newIndex = 1; // Ir al play/pause
                } else if (_currentFocusIndex == 1) {
                  newIndex = 2; // Ir al slider
                } else if (_currentFocusIndex == 2) {
                  // Para series: ir a episodes (3), para movies: ir a restart (3)
                  newIndex = 3;
                }
                // Validar el nuevo índice antes de asignarlo
                if (newIndex >= 0 && newIndex <= _maxFocusIndex) {
                  _currentFocusIndex = newIndex;
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
              bool eventHandled = _delegateKeyEventToPanels(event);
              if (eventHandled) {
                // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
                _controlsManager?.resetTimer();
                // Si es el episode panel, resetear su timer específico
                if (showEpisodePanel) {
                  _resetEpisodePanelTimer();
                }
              }
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              switch (_currentFocusIndex) {
                case 0: // Back button
                  Navigator.pop(context);
                  break;
                case 1: // Play/Pause
                  bloc.add(const VideoPlayerEvent.togglePlayPause());
                  break;
                case 2: // Slider - no hacer nada en select
                  break;
                case 3: // Episodes (series) or Restart (movies)
                  if (type == 'series') {
                    bloc.add(VideoPlayerEvent.loadEpisodes(seasonId: seasonId ?? 0));
                    _showEpisodePanel();
                  } else {
                    print('🔄 Activando Restart');
                    bloc.add(const VideoPlayerEvent.restart());
                  }
                  break;
                case 4: // Restart (series) or Audio (movies)
                  if (type == 'series') {
                    print('🔄 Activando Restart (series)');
                    bloc.add(const VideoPlayerEvent.restart());
                  } else {
                    print('🔊 Activando Audio panel (movies)');
                    bloc.add(VideoPlayerEvent.loadAudioTracks());
                    _showAudioPanel();
                  }
                  break;
                case 5: // Audio (series) or Subtitles (movies)
                  if (type == 'series') {
                    print('🔊 Activando Audio panel (series)');
                    bloc.add(VideoPlayerEvent.loadAudioTracks());
                    _showAudioPanel();
                  } else {
                    print('📝 Activando Subtitles panel (movies)');
                    bloc.add(VideoPlayerEvent.loadSubtitleTracks());
                    _showSubtitlePanel();
                  }
                  break;
                case 6: // Subtitles (series) or Quality/Settings (movies)
                  if (type == 'series') {
                    print('📝 Activando Subtitles panel (series)');
                    bloc.add(VideoPlayerEvent.loadSubtitleTracks());
                    _showSubtitlePanel();
                  } else {
                    print('⚙️ Activando Quality panel (movies)');
                    _showQualityPanel();
                  }
                  break;
                case 7: // Quality/Settings (series only)
                  if (type == 'series') {
                    print('⚙️ Activando Quality panel (series)');
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
          bloc.add(const VideoPlayerEvent.togglePlayPause());
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
          } else {}
          break;
      }
    }
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
            // Validar el focus al construir para prevenir estados inconsistentes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _validateAndCorrectFocus();
            });
            // _keyboardHandler?.updateState(
            //   currentFocusIndex: _currentFocusIndex,
            //   showSubtitlePanel: showSubtitlePanel,
            //   showAudioPanel: showAudioPanel,
            //   showQualityPanel: showQualityPanel,
            //   showEpisodePanel: showEpisodePanel,
            // );
            return KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: _handleKeyEvent,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (!state.controller.value.isBuffering || state.controller.value.isInitialized) {
                        if (_controlsManager?.showControls == true && state.controller.value.isBuffering == false && state.controller.value.isPlaying == true) {
                          print('👀 Ocultando controles');
                          _controlsManager?.hideControls();
                        } else {
                          print('👀 Mostrando controles y reiniciando timer');
                          _controlsManager?.show(); // fuerza a visible
                          showAudioPanel = false;
                          showSubtitlePanel = false;
                          showQualityPanel = false;
                          showEpisodePanel = false;
                          _controlsManager?.resetTimer(); // inicia autohide
                        }
                      }
                    },
                    child: Center(
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
                  ),
                  if (state.controller.value.isBuffering || state.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  if (_controlsManager?.showControls == true && state.controller.value.isBuffering == false)
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print(' 👀 Ocultando controles');
                            _controlsManager?.hideControls();
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.5), // inicio
                          ),
                        ),
                        Column(
                          children: [
                            SafeArea(
                              child: Padding(
                                padding: EdgeInsets.all(isTV ? 24 : 16),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: _isBackFocused ? Border.all(color: Colors.white, width: 2) : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                                        onPressed: () => Navigator.pop(context),
                                      ),
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
                                        GestureDetector(
                                          onTap: () {
                                            print('🎬 Cargando episodios con seasonId: $seasonId');
                                            bloc.add(VideoPlayerEvent.loadEpisodes(seasonId: seasonId ?? 0));
                                            _showEpisodePanel();
                                            _controlsManager?.resetTimer();
                                          },
                                          child: Container(
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
                                                    print('🎬 Cargando episodios con seasonId: $seasonId');
                                                    bloc.add(VideoPlayerEvent.loadEpisodes(seasonId: seasonId ?? 0));
                                                    _showEpisodePanel();
                                                    _controlsManager?.resetTimer();
                                                  },
                                                ),
                                                Text('Episodios', style: TextStyle(color: Colors.white, fontSize: isTV ? 18 : 14)),
                                                SizedBox(width: isTV ? 12 : 8),
                                              ],
                                            ),
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
                        if (_controlsManager?.showControls != true && state.controller.value.isInitialized)
                          GestureDetector(
                            onTap: () {
                              print(' 👀 Mostrando controles');
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
                              print('🎵 Cambiando pista de audio a $selectedIndex');
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
                            bloc: bloc,
                            key: _episodePanelKey,
                            title: 'Episodios',
                            isVisible: showEpisodePanel,
                            //  currentValue: state.episodeIndex.toString(),
                            // episodes: state.episodes,
                            onValueChanged: (EpisodeModel episode) {
                              bloc.add(
                                VideoPlayerEvent.changeEpisode(episode: episode),
                              );
                              _controlsManager?.hideControls();
                              showEpisodePanel = false;
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
}
