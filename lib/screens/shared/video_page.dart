import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/video_controller_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/video_controls_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/option_panel.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final bool isTV = PlatformUtils.isTV;
  String deviceId = "";
  VideoControllerManager? _videoManager;
  VideoControlsManager? _controlsManager;
  bool showSubtitlePanel = false;
  bool showAudioPanel = false;
  bool showQualityPanel = false;
  final FocusNode _focusNode = FocusNode();
  
  // TV Focus System
  int _currentFocusIndex = 0; // 0: play/pause, 1: slider, 2: restart, 3: audio, 4: subtitles, 5: settings
  final int _maxFocusIndex = 5;
  
  // Referencias a los paneles para navegación
  final GlobalKey<OptionPanelState> _subtitlePanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _audioPanelKey = GlobalKey<OptionPanelState>();
  final GlobalKey<OptionPanelState> _qualityPanelKey = GlobalKey<OptionPanelState>();
  
  // Focus states
  bool get _isPlayPauseFocused => isTV && _currentFocusIndex == 0;
  bool get _isSliderFocused => isTV && _currentFocusIndex == 1;
  bool get _isRestartFocused => isTV && _currentFocusIndex == 2;
  bool get _isAudioFocused => isTV && _currentFocusIndex == 3;
  bool get _isSubtitlesFocused => isTV && _currentFocusIndex == 4;
  bool get _isSettingsFocused => isTV && _currentFocusIndex == 5;
  
  @override
  void initState() {
    super.initState();
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
    
    _initializeManagers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  void _initializeManagers() {
    _videoManager = VideoControllerManager();
    _controlsManager = VideoControlsManager();
    
    _videoManager?.initializePlayer(
      'https://vz-62f65928-e3c.b-cdn.net/e924310a-57e3-44e2-ba63-3caf67ba0a36/playlist.m3u8',
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    
    _controlsManager?.initialize(
      onControlsChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _videoManager?.dispose();
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
    });
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
    });
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
    });
  }
  
  void _hideQualityPanel() {
    setState(() {
      showQualityPanel = false;
    });
  }
  
  // Helper methods to get dynamic options
  List<Map<String, String>> _getSubtitleOptions() {
    final subtitleTracks = _videoManager?.subtitleTracks ?? [];
    
    if (subtitleTracks.isEmpty) {
      return [
        {'label': 'No hay más subtítulos por el momento.', 'value': '0'}
      ];
    }
    
    return subtitleTracks.asMap().entries.map((entry) {
      final index = entry.key;
      final track = entry.value;
      return {
        'label': track['name'] ?? 'Subtítulo ${index + 1}',
        'value': index.toString()
      };
    }).toList();
  }
  
  List<Map<String, String>> _getAudioOptions() {
    final audioTracks = _videoManager?.audioTracks ?? [];
    
    if (audioTracks.isEmpty) {
      return [
        {'label': 'No hay más audio por el momento.', 'value': '0'}
      ];
    }
    
    return audioTracks.asMap().entries.map((entry) {
      final index = entry.key;
      final track = entry.value;
      return {
        'label': track['name'] ?? 'Audio ${index + 1}',
        'value': index.toString()
      };
    }).toList();
  }
  
  List<Map<String, String>> _getQualityOptions() {
    final qualityLevels = _videoManager?.qualityLevels ?? [];
    
    if (qualityLevels.isEmpty) {
      return [
        {'label': 'No hay más calidad por el momento.', 'value': '0'}
      ];
    }
    
    return qualityLevels.asMap().entries.map((entry) {
      final index = entry.key;
      final level = entry.value;
      return {
        'label': level['name'] ?? 'Calidad ${index + 1}',
        'value': index.toString()
      };
    }).toList();
  }
  
  // Método para delegar eventos de teclado a los paneles activos
  void _delegateKeyEventToPanels(KeyEvent event) {
    print('Delegating key event: ${event.logicalKey}');
    if (showSubtitlePanel) {
      print('Delegating to subtitle panel');
      _subtitlePanelKey.currentState?.handleKeyEvent(event);
    } else if (showAudioPanel) {
      print('Delegating to audio panel');
      _audioPanelKey.currentState?.handleKeyEvent(event);
    } else if (showQualityPanel) {
      print('Delegating to quality panel');
      _qualityPanelKey.currentState?.handleKeyEvent(event);
    }
  }
  
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          if (isTV) {
            if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
              // En paneles, no hacer nada con derecha
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else if (_isSliderFocused) {
              // Control del slider: +10 segundos
              final currentPos = _videoManager?.currentPosition ?? Duration.zero;
              final newPos = currentPos + Duration(seconds: 10);
              final maxPos = _videoManager?.totalDuration ?? Duration.zero;
              _videoManager?.seekTo(newPos > maxPos ? maxPos : newPos);
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
            if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
              // Salir de paneles con flecha izquierda
              _hideSubtitlePanel();
              _hideAudioPanel();
              _hideQualityPanel();
            } else if (_controlsManager!.showControls && _isSliderFocused) {
              // Control del slider: -10 segundos
              final currentPos = _videoManager?.currentPosition ?? Duration.zero;
              final newPos = currentPos - Duration(seconds: 10);
              _videoManager?.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
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
            if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
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
            if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
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
            if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
              // Delegar navegación a los paneles activos
              _delegateKeyEventToPanels(event);
              return;
            }
            if (!_controlsManager!.showControls) {
              _controlsManager?.show();
            } else {
              // Activar el elemento con focus
              switch (_currentFocusIndex) {
                case 0: // Play/Pause
                  _videoManager?.togglePlayPause();
                  break;
                case 1: // Slider - no hacer nada en select
                  break;
                case 2: // Restart
                  _videoManager?.restart();
                  break;
                case 3: // Audio
                  _showAudioPanel();
                  break;
                case 4: // Subtitles
                  _showSubtitlePanel();
                  break;
                case 5: // Settings/Quality
                  _showQualityPanel();
                  break;
              }
              _controlsManager?.resetTimer();
            }
          }
          break;
        case LogicalKeyboardKey.space:
          // Play/Pause para ambas plataformas
          _videoManager?.togglePlayPause();
          _controlsManager?.resetTimer();
          break;
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.goBack:
          if (showSubtitlePanel || showAudioPanel || showQualityPanel) {
            _hideSubtitlePanel();
            _hideAudioPanel();
            _hideQualityPanel();
          } else {
            Navigator.pop(context);
          }
          break;
      }
    }
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            // Video Player
            if (_videoManager?.controller != null)
              Center(
                child: VlcPlayer(
                  controller: _videoManager!.controller!,
                  aspectRatio: 16 / 9,
                  placeholder: Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            
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
                              icon: Icon(Icons.arrow_back_ios_new, 
                                color: Colors.white, 
                                size: isTV ? 36 : 28),
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
                                  border: _isPlayPauseFocused ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ) : null,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _videoManager?.hasEnded == true 
                                        ? Icons.replay 
                                        : (_videoManager?.isPlaying == true ? Icons.pause : Icons.play_arrow),
                                    color: Colors.white,
                                    size: isTV ? 48 : 32,
                                  ),
                                  onPressed: () async {
                                    await _videoManager?.togglePlayPause();
                                    _controlsManager?.resetTimer();
                                  },
                                ),
                              ),
                              SizedBox(width: isTV ? 24 : 16),
                              // Times
                              Text(
                                '${_videoManager?.formatDuration(_videoManager?.currentPosition ?? Duration.zero) ?? '0:00'} / ${_videoManager?.formatDuration(_videoManager?.totalDuration ?? Duration.zero) ?? '0:00'}',
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
                            decoration: _isSliderFocused ? BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ) : null,
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
                                value: (_videoManager?.totalDuration.inMilliseconds ?? 0) > 0
                                    ? (_videoManager?.currentPosition.inMilliseconds ?? 0) / (_videoManager?.totalDuration.inMilliseconds ?? 1)
                                    : 0.0,
                                onChanged: (value) {
                                  if (_videoManager?.controller != null && (_videoManager?.totalDuration.inMilliseconds ?? 0) > 0) {
                                    final position = Duration(
                                      milliseconds: (value * (_videoManager?.totalDuration.inMilliseconds ?? 0)).round(),
                                    );
                                    _videoManager?.seekTo(position);
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
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                decoration: isTV ? BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: _isRestartFocused ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ) : null,
                                ) : null,
                                child: IconButton(
                                  icon: Icon(Icons.replay, 
                                    color: Colors.white, 
                                    size: isTV ? 40 : 32),
                                  onPressed: () async {
                                    await _videoManager?.restart();
                                    _controlsManager?.resetTimer();
                                  },
                                ),
                              ),
                               
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                decoration: isTV ? BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: _isAudioFocused ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ) : null,
                                ) : null,
                                child: IconButton(
                                  icon: Icon(Icons.volume_up, 
                                    color: Colors.white, 
                                    size: isTV ? 40 : 32),
                                  onPressed: () {
                                    _showAudioPanel();
                                    _controlsManager?.resetTimer();
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                decoration: isTV ? BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: _isSubtitlesFocused ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ) : null,
                                ) : null,
                                child: IconButton(
                                  icon: Icon(Icons.closed_caption, 
                                    color: Colors.white, 
                                    size: isTV ? 40 : 32),
                                  onPressed: () {
                                    _showSubtitlePanel();
                                    _controlsManager?.resetTimer();
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
                                decoration: isTV ? BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: _isSettingsFocused ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ) : null,
                                ) : null,
                                child: IconButton(
                                  icon: Icon(Icons.settings, 
                                    color: Colors.white, 
                                    size: isTV ? 40 : 32),
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
                currentValue: _videoManager?.currentSubtitleIndex.toString() ?? '0',
                options: _getSubtitleOptions(),
                onValueChanged: (String index) {
                  final selectedIndex = int.tryParse(index) ?? 0;
                  _videoManager?.changeSubtitleTrack(selectedIndex);
                },
                onClose: _hideSubtitlePanel,
              ),
            
            // Audio Panel
            if (showAudioPanel)
              OptionPanel(
                key: _audioPanelKey,
                title: 'Audio',
                isVisible: showAudioPanel,
                currentValue: _videoManager?.currentAudioIndex.toString() ?? '0',
                options: _getAudioOptions(),
                onValueChanged: (String index) {
                  final selectedIndex = int.tryParse(index) ?? 0;
                  _videoManager?.changeAudioTrack(selectedIndex);
                },
                onClose: _hideAudioPanel,
              ),
            
            // Quality Panel
            if (showQualityPanel)
              OptionPanel(
                key: _qualityPanelKey,
                title: 'Calidad',
                isVisible: showQualityPanel,
                currentValue: _videoManager?.currentQualityIndex.toString() ?? '0',
                options: _getQualityOptions(),
                onValueChanged: (String index) {
                  final selectedIndex = int.tryParse(index) ?? 0;
                  _videoManager?.changeQualityLevel(selectedIndex);
                },
                onClose: _hideQualityPanel,
              ),
          ],
        ),
      ),
    );
  }
}
