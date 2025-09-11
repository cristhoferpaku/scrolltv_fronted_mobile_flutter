import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player/video_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/video_controls_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/episode_panel.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/option_panel.dart';

/// Callback para manejar cambios en el índice de foco
typedef FocusIndexCallback = void Function(int newIndex);

/// Callback para mostrar/ocultar paneles
typedef PanelCallback = void Function();

/// Callback para seleccionar episodio
typedef EpisodeSelectCallback = void Function(String episodeNum);

/// Callback para resetear timer del panel de episodios
typedef TimerResetCallback = void Function();

/// Componente que maneja toda la lógica de teclado para el reproductor de video
class VideoKeyboardHandler {
  // Sistema de repetición de teclas
  Timer? _keyRepeatTimer;
  LogicalKeyboardKey? _currentRepeatingKey;
  static const Duration _keyRepeatDelay = Duration(milliseconds: 500);
  static const Duration _keyRepeatInterval = Duration(milliseconds: 100);

  // Referencias necesarias
  final VideoPlayerBloc videoPlayerBloc;
  final VideoControlsManager? controlsManager;
  final bool isTV;
  final String? type;

  // Estado del foco
  int _currentFocusIndex;
  int get currentFocusIndex => _currentFocusIndex;
  int get maxFocusIndex => type == 'series' ? 6 : 5;

  // Estado de paneles
  bool _showSubtitlePanel;
  bool _showAudioPanel;
  bool _showQualityPanel;
  bool _showEpisodePanel;

  bool get showSubtitlePanel => _showSubtitlePanel;
  bool get showAudioPanel => _showAudioPanel;
  bool get showQualityPanel => _showQualityPanel;
  bool get showEpisodePanel => _showEpisodePanel;

  // Referencias a paneles
  final GlobalKey<OptionPanelState>? subtitlePanelKey;
  final GlobalKey<OptionPanelState>? audioPanelKey;
  final GlobalKey<OptionPanelState>? qualityPanelKey;
  final GlobalKey<EpisodePanelState>? episodePanelKey;

  // Callbacks
  final FocusIndexCallback? onFocusIndexChanged;
  final PanelCallback? onShowSubtitlePanel;
  final PanelCallback? onHideSubtitlePanel;
  final PanelCallback? onShowAudioPanel;
  final PanelCallback? onHideAudioPanel;
  final PanelCallback? onShowQualityPanel;
  final PanelCallback? onHideQualityPanel;
  final PanelCallback? onShowEpisodePanel;
  final PanelCallback? onHideEpisodePanel;
  final TimerResetCallback? onResetEpisodePanelTimer;
  final VoidCallback? onNavigateBack;

  VideoKeyboardHandler({
    required this.videoPlayerBloc,
    required this.controlsManager,
    required this.isTV,
    required this.type,
    required int currentFocusIndex,
    required bool showSubtitlePanel,
    required bool showAudioPanel,
    required bool showQualityPanel,
    required bool showEpisodePanel,
    this.subtitlePanelKey,
    this.audioPanelKey,
    this.qualityPanelKey,
    this.episodePanelKey,
    this.onFocusIndexChanged,
    this.onShowSubtitlePanel,
    this.onHideSubtitlePanel,
    this.onShowAudioPanel,
    this.onHideAudioPanel,
    this.onShowQualityPanel,
    this.onHideQualityPanel,
    this.onShowEpisodePanel,
    this.onHideEpisodePanel,
    this.onResetEpisodePanelTimer,
    this.onNavigateBack,
  })  : _currentFocusIndex = currentFocusIndex,
        _showSubtitlePanel = showSubtitlePanel,
        _showAudioPanel = showAudioPanel,
        _showQualityPanel = showQualityPanel,
        _showEpisodePanel = showEpisodePanel {
    // Debug: Verificar el valor de type
    print('VideoKeyboardHandler - type: "$type", maxFocusIndex: $maxFocusIndex');
  }

  /// Actualiza el estado del manejador de teclado
  void updateState({
    required int currentFocusIndex,
    required bool showSubtitlePanel,
    required bool showAudioPanel,
    required bool showQualityPanel,
    required bool showEpisodePanel,
  }) {
    _currentFocusIndex = currentFocusIndex;
    _showSubtitlePanel = showSubtitlePanel;
    _showAudioPanel = showAudioPanel;
    _showQualityPanel = showQualityPanel;
    _showEpisodePanel = showEpisodePanel;
  }

  // Focus states
  bool get isPlayPauseFocused => isTV && currentFocusIndex == 0;
  bool get isSliderFocused => isTV && currentFocusIndex == 1;
  bool get isEpisodesFocused => isTV && type == 'series' && currentFocusIndex == 2;
  bool get isRestartFocused => isTV && currentFocusIndex == (type == 'series' ? 3 : 2);
  bool get isAudioFocused => isTV && currentFocusIndex == (type == 'series' ? 4 : 3);
  bool get isSubtitlesFocused => isTV && currentFocusIndex == (type == 'series' ? 5 : 4);
  bool get isSettingsFocused => isTV && currentFocusIndex == (type == 'series' ? 6 : 5);

  /// Método principal para manejar eventos de teclado
  void handleKeyEvent(KeyEvent event) {
    // No responder a eventos de teclado si el video está cargando
    final currentState = videoPlayerBloc.state;
    if (currentState.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    // Manejar KeyUpEvent para cancelar repetición
    if (event is KeyUpEvent) {
      if (_currentRepeatingKey == event.logicalKey) {
        stopKeyRepeat();
      }
      return;
    }

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          _handleArrowRight(event);
          break;
        case LogicalKeyboardKey.arrowLeft:
          _handleArrowLeft(event);
          break;
        case LogicalKeyboardKey.arrowUp:
          _handleArrowUp(event);
          break;
        case LogicalKeyboardKey.arrowDown:
          _handleArrowDown(event);
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _handleSelectEnter(event);
          break;
        case LogicalKeyboardKey.space:
          _handleSpace();
          break;
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.goBack:
          _handleEscapeBack();
          break;
      }
    }
  }

  void _handleArrowRight(KeyEvent event) {
    if (isTV) {
      if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
        // En paneles, no hacer nada con derecha
        return;
      }
      if (controlsManager?.showControls != true) {
        controlsManager?.show();
      } else if (isSliderFocused) {
        // Control del slider con repetición: +10 segundos
        _startKeyRepeat(event.logicalKey, () => _performSeekAction(event.logicalKey));
      } else {
        // Navegar a la derecha entre controles
        final newIndex = (currentFocusIndex + 1) % (maxFocusIndex + 1);
        print('VideoKeyboardHandler - RIGHT: type="$type", currentIndex=$currentFocusIndex -> newIndex=$newIndex, maxIndex=$maxFocusIndex');
        onFocusIndexChanged?.call(newIndex);
        controlsManager?.resetTimer();
      }
    } else {
      if (!showSubtitlePanel) {
        onShowSubtitlePanel?.call();
      }
    }
  }

  void _handleArrowLeft(KeyEvent event) {
    if (isTV) {
      if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
        // Primero delegar al panel activo para navegación interna
        bool eventHandled = _delegateKeyEventToPanels(event);
        if (eventHandled) {
          // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
          controlsManager?.resetTimer();
          // Si es el episode panel, resetear su timer específico
          if (showEpisodePanel) {
            onResetEpisodePanelTimer?.call();
          }
        } else {
          // Solo cerrar paneles si no hay navegación interna disponible
          _hideAllPanels();
          controlsManager?.resetTimer();
        }
      } else if (controlsManager?.showControls == true && isSliderFocused) {
        // Control del slider con repetición: -10 segundos
        _startKeyRepeat(event.logicalKey, () => _performSeekAction(event.logicalKey));
      } else if (controlsManager?.showControls == true) {
        // Navegar a la izquierda entre controles
        final newIndex = currentFocusIndex == 0 ? maxFocusIndex : currentFocusIndex - 1;
        print('VideoKeyboardHandler - LEFT: type="$type", currentIndex=$currentFocusIndex -> newIndex=$newIndex, maxIndex=$maxFocusIndex');
        onFocusIndexChanged?.call(newIndex);
        controlsManager?.resetTimer();
      } else {
        return;
      }
    } else {
      if (showSubtitlePanel) {
        onHideSubtitlePanel?.call();
      }
      onHideAudioPanel?.call();
      onHideQualityPanel?.call();
    }
  }

  void _handleArrowUp(KeyEvent event) {
    if (isTV) {
      if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
        // Delegar navegación a los paneles activos
        bool eventHandled = _delegateKeyEventToPanels(event);
        if (eventHandled) {
          // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
          controlsManager?.resetTimer();
          // Si es el episode panel, resetear su timer específico
          if (showEpisodePanel) {
            onResetEpisodePanelTimer?.call();
          }
        }
        return;
      }
      if (controlsManager?.showControls != true) {
        controlsManager?.show();
      } else {
        // Navegar hacia arriba: de botones inferiores a slider o play/pause
        int newIndex = currentFocusIndex;
        if (currentFocusIndex >= 2) {
          newIndex = 1; // Ir al slider
        } else if (currentFocusIndex == 1) {
          newIndex = 0; // Ir al play/pause
        }
        onFocusIndexChanged?.call(newIndex);
        controlsManager?.resetTimer();
      }
    }
  }

  void _handleArrowDown(KeyEvent event) {
    if (isTV) {
      if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
        // Delegar navegación a los paneles activos
        bool eventHandled = _delegateKeyEventToPanels(event);
        if (eventHandled) {
          // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
          controlsManager?.resetTimer();
          // Si es el episode panel, resetear su timer específico
          if (showEpisodePanel) {
            onResetEpisodePanelTimer?.call();
          }
        }
        return;
      }
      if (controlsManager?.showControls != true) {
        controlsManager?.show();
      } else {
        // Navegar hacia abajo: de play/pause a slider, de slider a botones
        int newIndex = currentFocusIndex;
        if (currentFocusIndex == 0) {
          newIndex = 1; // Ir al slider
        } else if (currentFocusIndex == 1) {
          newIndex = 2; // Ir a los botones (restart)
        }
        onFocusIndexChanged?.call(newIndex);
        controlsManager?.resetTimer();
      }
    }
  }

  void _handleSelectEnter(KeyEvent event) {
    if (isTV) {
      if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
        // Delegar navegación a los paneles activos
        bool eventHandled = _delegateKeyEventToPanels(event);
        if (eventHandled) {
          // Si el evento fue manejado por un panel, resetear el timer para mantener controles visibles
          controlsManager?.resetTimer();
          // Si es el episode panel, resetear su timer específico
          if (showEpisodePanel) {
            onResetEpisodePanelTimer?.call();
          }
        }
        return;
      }
      if (controlsManager?.showControls != true) {
        controlsManager?.show();
      } else {
        // Debug: Verificar qué acción se ejecuta
        print('VideoKeyboardHandler - SELECT pressed: type="$type", currentFocusIndex=$currentFocusIndex');

        // Activar el elemento con focus
        switch (currentFocusIndex) {
          case 0: // Play/Pause
            print('VideoKeyboardHandler - Executing: togglePlayPause');
            videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
            break;
          case 1: // Slider - no hacer nada en select
            print('VideoKeyboardHandler - Slider focused - no action');
            break;
          case 2: // Episodes (series only) or Restart (movies)
            if (type == 'series') {
              print('VideoKeyboardHandler - Executing: showEpisodePanel (series)');
              onShowEpisodePanel?.call();
            } else {
              print('VideoKeyboardHandler - Executing: restart (movie)');
              videoPlayerBloc.add(const VideoPlayerEvent.restart());
            }
            break;
          case 3: // Restart (series) or Audio (movies)
            if (type == 'series') {
              print('VideoKeyboardHandler - Executing: restart (series)');
              videoPlayerBloc.add(const VideoPlayerEvent.restart());
            } else {
              print('VideoKeyboardHandler - Executing: showAudioPanel (movie)');
              onShowAudioPanel?.call();
            }
            break;
          case 4: // Audio (series) or Subtitles (movies)
            if (type == 'series') {
              print('VideoKeyboardHandler - Executing: showAudioPanel (series)');
              onShowAudioPanel?.call();
            } else {
              print('VideoKeyboardHandler - Executing: showSubtitlePanel (movie)');
              onShowSubtitlePanel?.call();
            }
            break;
          case 5: // Subtitles (series) or Settings (movies)
            if (type == 'series') {
              print('VideoKeyboardHandler - Executing: showSubtitlePanel (series)');
              onShowSubtitlePanel?.call();
            } else {
              print('VideoKeyboardHandler - Executing: showQualityPanel (movie)');
              onShowQualityPanel?.call();
            }
            break;
          case 6: // Settings (series only)
            if (type == 'series') {
              print('VideoKeyboardHandler - Executing: showQualityPanel (series)');
              onShowQualityPanel?.call();
            }
            break;
        }
        controlsManager?.resetTimer();
      }
    }
  }

  void _handleSpace() {
    // Play/Pause para ambas plataformas
    videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
    controlsManager?.resetTimer();
  }

  void _handleEscapeBack() {
    if (showSubtitlePanel || showAudioPanel || showQualityPanel || showEpisodePanel) {
      _hideAllPanels();
      controlsManager?.resetTimer();
    } else {
      // Limpiar recursos del video player antes de navegar
      videoPlayerBloc.add(const VideoPlayerEvent.dispose());
      controlsManager?.dispose();
      onNavigateBack?.call();
    }
  }

  /// Delegar eventos de teclado a los paneles activos
  bool _delegateKeyEventToPanels(KeyEvent event) {
    if (showSubtitlePanel) {
      return subtitlePanelKey?.currentState?.handleKeyEvent(event) ?? false;
    } else if (showAudioPanel) {
      return audioPanelKey?.currentState?.handleKeyEvent(event) ?? false;
    } else if (showQualityPanel) {
      return qualityPanelKey?.currentState?.handleKeyEvent(event) ?? false;
    } else if (showEpisodePanel) {
      return episodePanelKey?.currentState?.handleKeyEvent(event) ?? false;
    }
    return false;
  }

  /// Ocultar todos los paneles
  void _hideAllPanels() {
    onHideSubtitlePanel?.call();
    onHideAudioPanel?.call();
    onHideQualityPanel?.call();
    onHideEpisodePanel?.call();
  }

  /// Iniciar repetición de teclas
  void _startKeyRepeat(LogicalKeyboardKey key, VoidCallback action) {
    stopKeyRepeat();
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

  /// Detener repetición de teclas
  void stopKeyRepeat() {
    _keyRepeatTimer?.cancel();
    _keyRepeatTimer = null;
    _currentRepeatingKey = null;
  }

  /// Ejecutar acciones de seek
  void _performSeekAction(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowRight) {
      videoPlayerBloc.add(const VideoPlayerEvent.skipForward(seconds: 10));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      videoPlayerBloc.add(const VideoPlayerEvent.skipBackward(seconds: 10));
    }
    controlsManager?.resetTimer();
  }

  /// Limpiar recursos
  void dispose() {
    stopKeyRepeat();
  }
}
