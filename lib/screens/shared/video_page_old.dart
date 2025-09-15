// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
// import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
// import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/episode_model.dart';
// import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/components/video_keyboard_handler.dart';
// import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player copy/video_player_bloc.dart';
// import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
// import 'package:scrolltv_frontend_mobile_flutter/util/util_functions.dart';
// import 'package:scrolltv_frontend_mobile_flutter/util/video_controls_manager.dart';
// import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/episode_panel.dart';
// import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/option_panel.dart';
// import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/video_player_skeleton.dart';

// class VideoPage extends StatefulWidget {
//   const VideoPage({super.key});

//   @override
//   State<VideoPage> createState() => _VideoPageState();
// }

// class VideoPageWrapper extends StatelessWidget {
//   const VideoPageWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const VideoPage();
//   }
// }

// class _VideoPageState extends State<VideoPage> {
//   String videoUrl = '';
//   int videoId = 0;
//   int? seasonId;
//   int? episodeNumber;
//   String? type;
//   final bool isTV = PlatformUtils.isTV;
//   String deviceId = "";
//   VideoControlsManager? _controlsManager;
//   late VideoPlayerBloc _videoPlayerBloc;
//   bool showSubtitlePanel = false;
//   bool showAudioPanel = false;
//   bool showQualityPanel = false;
//   bool showEpisodePanel = false;

//   // Estado local para pistas de audio y subtítulos (como en la demo oficial)
//   List<Map<String, String>> _subtitleTracks = [];
//   List<Map<String, String>> _audioTracks = [];
//   int _currentSubtitleIndex = 0;
//   int _currentAudioIndex = 0;
//   bool _tracksLoaded = false;

//   // Timer específico para el episode panel
//   Timer? _episodePanelTimer;

//   final FocusNode _focusNode = FocusNode();

//   // TV Focus System
//   int _currentFocusIndex = 0; // 0: play/pause, 1: slider, 2: restart, 3: audio, 4: subtitles, 5: episodes (series only), 6: settings
//   int get _maxFocusIndex => type == 'series' ? 6 : 5;

//   // Referencias a los paneles para navegación
//   final GlobalKey<OptionPanelState> _subtitlePanelKey = GlobalKey<OptionPanelState>();
//   final GlobalKey<OptionPanelState> _audioPanelKey = GlobalKey<OptionPanelState>();
//   final GlobalKey<OptionPanelState> _qualityPanelKey = GlobalKey<OptionPanelState>();
//   final GlobalKey<EpisodePanelState> _episodePanelKey = GlobalKey<EpisodePanelState>();

//   // Manejador de teclado
//   VideoKeyboardHandler? _keyboardHandler;

//   // Focus states
//   bool get _isPlayPauseFocused => isTV && _currentFocusIndex == 0;
//   bool get _isSliderFocused => isTV && _currentFocusIndex == 1;
//   bool get _isEpisodesFocused => isTV && type == 'series' && _currentFocusIndex == 2;
//   bool get _isRestartFocused => isTV && _currentFocusIndex == (type == 'series' ? 3 : 2);
//   bool get _isAudioFocused => isTV && _currentFocusIndex == (type == 'series' ? 4 : 3);
//   bool get _isSubtitlesFocused => isTV && _currentFocusIndex == (type == 'series' ? 5 : 4);
//   bool get _isSettingsFocused => isTV && _currentFocusIndex == (type == 'series' ? 6 : 5);

//   @override
//   void initState() {
//     super.initState();
//     _videoPlayerBloc = instance<VideoPlayerBloc>();

//     // Resetear estado de pistas para nuevo video
//     _resetTracksState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final args = ModalRoute.of(context)!.settings.arguments as VideoPageArguments;
//       videoUrl = args.videoUrl;
//       videoId = args.videoId;
//       seasonId = args.seasonId;
//       episodeNumber = args.episodeNumber;
//       type = args.type;

//       // Debug: Verificar el valor de type recibido
//       print('VideoPage - Received type: "$type"');

//       // Inicializar el video player con VideoPlayerBloc
//       _videoPlayerBloc.add(VideoPlayerEvent.initialize(videoUrl: videoUrl));

//       // Inicializar el listener para cargar pistas
//       _initializeTracksListener();

//       // Inicializar el manejador de teclado después de obtener type
//       _initializeKeyboardHandler();

//       _focusNode.requestFocus();
//     });
//   }

//   // Resetear estado de pistas cuando se carga un nuevo video
//   void _resetTracksState() {
//     _subtitleTracks = [];
//     _audioTracks = [];
//     _currentSubtitleIndex = 0;
//     _currentAudioIndex = 0;
//     _tracksLoaded = false;
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!isTV) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ]);
//     }

//     PlatformUtils().getDeviceId().then((value) {
//       setState(() {
//         deviceId = value;
//       });
//     });

//     _initializeControlsManager();
//   }

//   void _initializeControlsManager() {
//     _controlsManager = VideoControlsManager();

//     _controlsManager?.initialize(
//       onControlsChanged: () {
//         if (mounted) {
//           setState(() {});
//         }
//       },
//       onControlsHidden: () {
//         if (mounted) {
//           // Solo cerrar paneles si no hay interacción activa
//           // El episode panel no se cierra automáticamente para permitir navegación
//           setState(() {
//             showSubtitlePanel = false;
//             showAudioPanel = false;
//             showQualityPanel = false;
//             // showEpisodePanel se mantiene abierto durante la interacción
//           });
//         }
//       },
//     );
//   }

//   void _initializeTracksListener() {
//     // Escuchar cambios en el estado del video player para cargar pistas
//     _videoPlayerBloc.stream.listen((state) {
//       final controller = state.controller ?? _videoPlayerBloc.controller;
//       if (controller != null && !_tracksLoaded) {
//         // Agregar listener al controller para detectar cuando empiece a reproducir
//         controller.addListener(() {
//           if (controller.value.isPlaying && !_tracksLoaded) {
//             // Esperar un poco para que el video se estabilice antes de cargar pistas
//             Future.delayed(const Duration(milliseconds: 1500), () {
//               if (mounted) {
//                 _loadVideoTracks(controller);
//               }
//             });
//           }
//         });
//       }
//     });
//   }

//   void _initializeKeyboardHandler() {
//     // Debug: Verificar el valor de type al inicializar VideoKeyboardHandler
//     print('VideoPage - Initializing VideoKeyboardHandler with type: "$type"');

//     _keyboardHandler = VideoKeyboardHandler(
//       videoPlayerBloc: _videoPlayerBloc,
//       controlsManager: _controlsManager,
//       isTV: isTV,
//       type: type,
//       currentFocusIndex: _currentFocusIndex,
//       showSubtitlePanel: showSubtitlePanel,
//       showAudioPanel: showAudioPanel,
//       showQualityPanel: showQualityPanel,
//       showEpisodePanel: showEpisodePanel,
//       subtitlePanelKey: _subtitlePanelKey,
//       audioPanelKey: _audioPanelKey,
//       qualityPanelKey: _qualityPanelKey,
//       episodePanelKey: _episodePanelKey,
//       onFocusIndexChanged: (newIndex) {
//         setState(() {
//           _currentFocusIndex = newIndex;
//         });
//       },
//       onShowSubtitlePanel: _showSubtitlePanel,
//       onHideSubtitlePanel: _hideSubtitlePanel,
//       onShowAudioPanel: _showAudioPanel,
//       onHideAudioPanel: _hideAudioPanel,
//       onShowQualityPanel: _showQualityPanel,
//       onHideQualityPanel: _hideQualityPanel,
//       onShowEpisodePanel: _showEpisodePanel,
//       onHideEpisodePanel: _hideEpisodePanel,
//       onResetEpisodePanelTimer: _resetEpisodePanelTimer,
//       onNavigateBack: () {
//         //Navigator.pop(context);  no hacer esto porque hace eso
//       },
//     );
//   }

//   @override
//   void deactivate() {
//     // Detener el video antes de que se desactive la vista para evitar crashes
//     _videoPlayerBloc.add(const VideoPlayerEvent.pause());
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     _keyboardHandler?.dispose();
//     // Detener completamente el reproductor antes de liberar recursos
//     _videoPlayerBloc.add(const VideoPlayerEvent.stop());
//     _videoPlayerBloc.add(const VideoPlayerEvent.dispose());
//     _controlsManager?.dispose();
//     _cancelEpisodePanelTimer();
//     _focusNode.dispose();

//     if (!isTV) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//     }
//     super.dispose();
//   }

//   void _showSubtitlePanel() {
//     setState(() {
//       showSubtitlePanel = true;
//       showAudioPanel = false;
//       showQualityPanel = false;
//       showEpisodePanel = false;
//     });
//     // Reiniciar timer cuando se abre un panel
//     _controlsManager?.resetTimer();
//   }

//   void _hideSubtitlePanel() {
//     setState(() {
//       showSubtitlePanel = false;
//     });
//   }

//   void _showAudioPanel() {
//     setState(() {
//       showAudioPanel = true;
//       showSubtitlePanel = false;
//       showQualityPanel = false;
//       showEpisodePanel = false;
//     });
//     // Reiniciar timer cuando se abre un panel
//     _controlsManager?.resetTimer();
//   }

//   void _hideAudioPanel() {
//     setState(() {
//       showAudioPanel = false;
//     });
//   }

//   void _showQualityPanel() {
//     setState(() {
//       showQualityPanel = true;
//       showSubtitlePanel = false;
//       showAudioPanel = false;
//       showEpisodePanel = false;
//     });
//     // Reiniciar timer cuando se abre un panel
//     _controlsManager?.resetTimer();
//   }

//   void _hideQualityPanel() {
//     setState(() {
//       showQualityPanel = false;
//     });
//   }

//   void _showEpisodePanel() {
//     // La carga de episodios ahora se maneja automáticamente en _getEpisodeOptions()
//     // cuando el EpisodePanel se renderiza, evitando llamadas duplicadas

//     setState(() {
//       showEpisodePanel = true;
//       showSubtitlePanel = false;
//       showAudioPanel = false;
//       showQualityPanel = false;
//     });
//     // Reiniciar timer cuando se abre un panel
//     _controlsManager?.resetTimer();
//     // Iniciar timer específico para el episode panel
//     _startEpisodePanelTimer();
//   }

//   void _hideEpisodePanel() {
//     _cancelEpisodePanelTimer();
//     setState(() {
//       showEpisodePanel = false;
//     });
//   }

//   // Métodos para manejar el timer específico del episode panel
//   void _startEpisodePanelTimer() {
//     _cancelEpisodePanelTimer();
//     _episodePanelTimer = Timer(Duration(seconds: 8), () {
//       if (mounted && showEpisodePanel) {
//         _hideEpisodePanel();
//       }
//     });
//   }

//   void _cancelEpisodePanelTimer() {
//     _episodePanelTimer?.cancel();
//     _episodePanelTimer = null;
//   }

//   void _resetEpisodePanelTimer() {
//     if (showEpisodePanel) {
//       _startEpisodePanelTimer();
//     }
//   }

//   // Helper methods to get dynamic options
//   List<Map<String, String>> _getSubtitleOptions(VideoPlayerState state) {
//     if (_subtitleTracks.isNotEmpty) {
//       return _subtitleTracks.asMap().entries.map((entry) {
//         final index = entry.key;
//         final track = entry.value;
//         return {'label': track['name'] ?? 'Subtítulo ${index + 1}', 'value': index.toString()};
//       }).toList();
//     }

//     // Si las pistas ya se cargaron pero están vacías, mostrar mensaje
//     if (_tracksLoaded && _subtitleTracks.isEmpty) {
//       return [
//         {'label': 'No hay más subtítulos por el momento.', 'value': '0'}
//       ];
//     }

//     // Devolver lista vacía mientras se cargan las pistas para mostrar skeleton
//     return [];
//   }

//   List<Map<String, String>> _getAudioOptions(VideoPlayerState state) {
//     if (_audioTracks.isNotEmpty) {
//       return _audioTracks.asMap().entries.map((entry) {
//         final index = entry.key;
//         final track = entry.value;
//         return {'label': track['name'] ?? 'Audio ${index + 1}', 'value': index.toString()};
//       }).toList();
//     }

//     // Si las pistas ya se cargaron pero están vacías, mostrar mensaje
//     if (_tracksLoaded) {
//       return [
//         {'label': 'No hay más audio por el momento.', 'value': '0'}
//       ];
//     }

//     // Devolver lista vacía mientras se cargan las pistas para mostrar skeleton
//     return [];
//   }

//   List<Map<String, String>> _getQualityOptions() {
//     // Solo mostrar opción automática - funcionalidad de calidad eliminada
//     return [
//       {'label': 'Automática', 'value': '0'}
//     ];
//   }

//   List<EpisodeModel> _getEpisodeOptions() {
//     // Obtener episodios del estado del bloc
//     final blocEpisodes = _videoPlayerBloc.state.episodes;

//     // Si ya tenemos episodios, devolverlos directamente
//     if (blocEpisodes.isNotEmpty) {
//       return blocEpisodes;
//     }

//     // Solo hacer la llamada si es una serie, tenemos seasonId y NO estamos en estado de carga
//     // Esto evita llamadas múltiples durante el renderizado
//     if (type == 'series' && seasonId != null) {
//       final currentState = _videoPlayerBloc.state;
//       // Solo cargar si no estamos ya en proceso de carga
//       if (!currentState.maybeWhen(
//         loading: (_) => true,
//         orElse: () => false,
//       )) {
//         print('🔄 Solicitando carga de episodios para seasonId: $seasonId');
//         _videoPlayerBloc.add(VideoPlayerEvent.loadEpisodes(seasonId: seasonId!));
//       }
//     }

//     // Retornar lista vacía mientras cargan los episodios
//     return [];
//   }

//   String _getCurrentEpisodeValue() {
//     // Si tenemos un episodeNumber definido, usarlo
//     if (episodeNumber != null) {
//       return episodeNumber.toString();
//     }

//     // Si no, obtener el primer episodio disponible solo si ya están cargados
//     final episodes = _getEpisodeOptions();
//     if (episodes.isNotEmpty) {
//       return episodes.first.episodeNumber.toString();
//     }

//     // Si los episodios aún se están cargando, usar el episodeNumber de los argumentos si existe
//     final args = ModalRoute.of(context)?.settings.arguments as VideoPageArguments?;
//     if (args?.episodeNumber != null) {
//       return args!.episodeNumber.toString();
//     }

//     // Fallback a '1' solo si no hay otra opción
//     return '1';
//   }

//   void _selectEpisode(String episodeNum) {
//     // Cancelar timers al cambiar de episodio
//     _cancelEpisodePanelTimer();
//     _keyboardHandler?.stopKeyRepeat();

//     // Obtener episodios usando el método _getEpisodeOptions
//     final episodes = _getEpisodeOptions();

//     if (episodes.isNotEmpty && episodeNum != '0') {
//       final selectedEpisodeData = episodes.firstWhere(
//         (episode) => episode.episodeNumber.toString() == episodeNum,
//         orElse: () => episodes.first,
//       );

//       // Actualizar el estado primero para que el panel muestre la selección correcta
//       setState(() {
//         episodeNumber = selectedEpisodeData.episodeNumber;
//         videoId = selectedEpisodeData.episodeId ?? 0;
//       });

//       // Forzar actualización del EpisodePanel
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _episodePanelKey.currentState?.forceUpdateSelectedIndex();
//         if (selectedEpisodeData.videoUrl != null && selectedEpisodeData.videoUrl!.isNotEmpty) {
//           _resetTracksState();
//           _videoPlayerBloc.add(VideoPlayerEvent.initialize(
//             videoUrl: selectedEpisodeData.videoUrl!,
//           ));
//           // Inicializar el listener para cargar pistas
//           _initializeTracksListener();

//           // Inicializar el manejador de teclado después de obtener type
//           _initializeKeyboardHandler();

//           _focusNode.requestFocus();
//         }
//       });

//       // Solo inicializar el reproductor si hay una URL válida

//       // Esperar un frame para que el estado se actualice antes de cerrar el panel
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // Cerrar el panel después de un breve delay para mostrar la selección
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             _hideEpisodePanel();
//           }
//         });
//       });
//     } else {
//       // Si no hay episodio válido, cerrar inmediatamente
//       _hideEpisodePanel();
//     }
//   }

//   Widget _buildVideoPlayer(VideoPlayerState state) {
//     // Siempre renderizar VlcPlayer como en la demo oficial
//     // El controller se obtiene del state o del Bloc como fallback
//     final controller = state.controller ?? _videoPlayerBloc.controller;

//     // Si hay error, mostrar mensaje de error
//     if (state.maybeWhen(
//       error: (message) => true,
//       orElse: () => false,
//     )) {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Text(
//             'Error: ${state.maybeWhen(error: (message) => message, orElse: () => "")}',
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

//     // Verificar si está en buffering
//     final isBuffering = state.maybeWhen(
//       loading: (_) => true,
//       orElse: () => false,
//     );

//     // Mostrar VlcPlayer siempre que tengamos controller, nunca quitarlo del árbol
//     return Center(
//       child: controller != null
//           ? Stack(
//               children: [
//                 VlcPlayer(
//                   key: ValueKey(videoUrl), // Forzar reconstrucción cuando cambie la URL
//                   controller: controller,
//                   aspectRatio: 16 / 9,
//                   placeholder: const VideoPlayerSkeleton(), // solo al inicio
//                 ),
//                 // Overlay durante buffering
//                 if (isBuffering)
//                   const Positioned.fill(
//                     child: VideoPlayerSkeleton(), // overlay durante buffering
//                   ),
//               ],
//             )
//           : const VideoPlayerSkeleton(), // si aún no existe controller
//     );
//   }

//   // return Center(
//   //   child: controller != null
//   //       ? VlcPlayer(
//   //           controller: controller,
//   //           aspectRatio: 16 / 9,
//   //           placeholder: const VideoPlayerSkeleton(),
//   //         )
//   //       : const VideoPlayerSkeleton(),
//   // );
//   Future<void> _loadVideoTracks(VlcPlayerController controller) async {
//     if (_tracksLoaded) return;
//     try {
//       bool foundSubtitles = false;
//       bool foundAudio = false;
//       final subtitleList = <Map<String, String>>[];
//       final audioList = <Map<String, String>>[];

//       print('\n=== CARGANDO PISTAS DE VIDEO (DIRECTO) ===');

//       // Cargar subtítulos con timeout
//       try {
//         final spuCount = await controller.getSpuTracks().timeout(
//           const Duration(milliseconds: 1000),
//           onTimeout: () {
//             print('⏱️ Timeout obteniendo subtítulos');
//             return <int, String>{};
//           },
//         );

//         // Agregar opción "Desactivados" primero
//         subtitleList.add({'id': '-1', 'name': 'Desactivados'});
//         if (spuCount.isNotEmpty) {
//           final sortedTracks = spuCount.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
//           for (final entry in sortedTracks) {
//             subtitleList.add({'id': entry.key.toString(), 'name': entry.value});
//           }
//           foundSubtitles = true;
//           print('📝 SUBTÍTULOS ENCONTRADOS: ${spuCount.length} pistas');
//         } else {
//           print('❌ No se encontraron pistas de subtítulos');
//         }
//       } catch (e) {
//         subtitleList.add({'id': '-1', 'name': 'Desactivados'});
//         print('❌ Error obteniendo subtítulos: $e');
//       }

//       // Cargar audio con timeout
//       try {
//         final audio = await controller.getAudioTracks().timeout(
//           const Duration(milliseconds: 1000),
//           onTimeout: () {
//             print('⏱️ Timeout obteniendo audio');
//             return <int, String>{};
//           },
//         );

//         if (audio.isNotEmpty) {
//           final sortedAudioTracks = audio.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
//           for (final entry in sortedAudioTracks) {
//             audioList.add({'id': entry.key.toString(), 'name': entry.value});
//           }
//           foundAudio = true;
//           print('🔊 AUDIOS ENCONTRADOS: ${audio.length} pistas');
//         } else {
//           print('❌ No se encontraron pistas de audio específicas');
//         }
//       } catch (e) {
//         print('❌ Error obteniendo audio: $e');
//       }

//       // Actualizar estado local
//       if (mounted) {
//         setState(() {
//           _subtitleTracks = subtitleList;
//           _audioTracks = audioList.isNotEmpty
//               ? audioList
//               : [
//                   {'id': '0', 'name': 'Audio Principal'}
//                 ];
//           _currentSubtitleIndex = 0; // Desactivados por defecto
//           _currentAudioIndex = 0;
//           _tracksLoaded = true;
//         });
//       }
//     } catch (e) {
//       print('❌ Error al cargar pistas: $e');
//       if (mounted) {
//         setState(() {
//           _subtitleTracks = [
//             {'id': '-1', 'name': 'Desactivados'}
//           ];
//           _audioTracks = [
//             {'id': '0', 'name': 'Audio Principal'}
//           ];
//           _currentSubtitleIndex = 0;
//           _currentAudioIndex = 0;
//           _tracksLoaded = true;
//         });
//       }
//     }
//   }

//   // Cambiar pista de subtítulos directamente (como en la demo oficial)
//   Future<void> _changeSubtitleTrack(VlcPlayerController controller, int index) async {
//     if (index >= _subtitleTracks.length) return;

//     try {
//       if (index == 0) {
//         // Desactivar subtítulos
//         await controller.setSpuTrack(-1);
//         print('🔇 Subtítulos desactivados');
//       } else {
//         // Obtener el nombre de la pista deseada
//         final desiredTrackName = _subtitleTracks[index]['name'];
//         // Obtener pistas actuales del VLC para obtener los IDs reales
//         final currentTracks = await controller.getSpuTracks();

//         if (currentTracks.isNotEmpty) {
//           // Encontrar el ID de la pista que coincide con el nombre deseado
//           int? targetTrackId;
//           for (final entry in currentTracks.entries) {
//             if (entry.value == desiredTrackName) {
//               targetTrackId = entry.key;
//               break;
//             }
//           }

//           if (targetTrackId != null) {
//             await controller.setSpuTrack(targetTrackId);
//             print('📝 Subtítulo cambiado a: $desiredTrackName (ID: $targetTrackId)');
//           }
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _currentSubtitleIndex = index;
//         });
//       }
//     } catch (e) {
//       print('❌ Error cambiando subtítulo: $e');
//     }
//   }

//   // Cambiar pista de audio directamente (como en la demo oficial)
//   Future<void> _changeAudioTrack(VlcPlayerController controller, int index) async {
//     if (index >= _audioTracks.length) return;

//     try {
//       // Obtener el nombre de la pista deseada
//       final desiredTrackName = _audioTracks[index]['name'];
//       // Obtener pistas actuales del VLC para obtener los IDs reales
//       final currentTracks = await controller.getAudioTracks();

//       if (currentTracks.isNotEmpty) {
//         // Encontrar el ID de la pista que coincide con el nombre deseado
//         int? targetTrackId;
//         for (final entry in currentTracks.entries) {
//           if (entry.value == desiredTrackName) {
//             targetTrackId = entry.key;
//             break;
//           }
//         }

//         if (targetTrackId != null) {
//           await controller.setAudioTrack(targetTrackId);
//           print('🔊 Audio cambiado a: $desiredTrackName (ID: $targetTrackId)');
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _currentAudioIndex = index;
//         });
//       }
//     } catch (e) {
//       print('❌ Error cambiando audio: $e');
//     }
//   }

//   // Método para delegar eventos de teclado a los paneles activos
//   // Métodos de manejo de teclado movidos a VideoKeyboardHandler

//   @override
//   Widget build(BuildContext context) {
//     // Actualizar el estado del manejador de teclado
//     _keyboardHandler?.updateState(
//       currentFocusIndex: _currentFocusIndex,
//       showSubtitlePanel: showSubtitlePanel,
//       showAudioPanel: showAudioPanel,
//       showQualityPanel: showQualityPanel,
//       showEpisodePanel: showEpisodePanel,
//     );

//     return BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
//       bloc: _videoPlayerBloc,
//       listener: (context, state) {
//         // Establecer episodeNumber cuando se carguen los episodios por primera vez
//         state.whenOrNull(
//           ready: (url, controller, currentPosition, duration, isPlaying, hasEnded, subtitleTracks, audioTracks, currentSubtitleIndex, currentAudioIndex, currentSubtitle, episodes, tracksLoaded) {
//             if (type == 'series' && episodeNumber == null && episodes.isNotEmpty) {
//               setState(() {
//                 episodeNumber = episodes.first.episodeNumber;
//               });
//             }
//           },
//         );
//       },
//       builder: (context, state) {
//         return WillPopScope(
//           onWillPop: () async {
//             // Detener el video antes de salir para evitar crashes
//             _videoPlayerBloc.add(const VideoPlayerEvent.stop());
//             // Pequeña pausa para asegurar que el video se detenga
//             await Future.delayed(const Duration(milliseconds: 100));
//             return true;
//           },
//           child: Scaffold(
//             backgroundColor: Colors.black,
//             body: KeyboardListener(
//               focusNode: _focusNode,
//               onKeyEvent: _keyboardHandler?.handleKeyEvent,
//               child: Stack(
//                 children: [
//                   // Video Player
//                   _buildVideoPlayer(state),

//                   // Controls Overlay - Solo mostrar si no está cargando
//                   if (_controlsManager?.showControls == true &&
//                       !state.maybeWhen(
//                         loading: (_) => true,
//                         orElse: () => false,
//                       ))
//                     Stack(
//                       children: [
//                         // Background tap to hide controls
//                         GestureDetector(
//                           onTap: () {
//                             _controlsManager?.hideControls();
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             height: double.infinity,
//                             color: Colors.black.withOpacity(0.5), // inicio
//                           ),
//                         ),
//                         // Controls that don't hide when tapped
//                         GestureDetector(
//                           onTap: () {
//                             _controlsManager?.resetTimer();
//                           }, // Prevent tap from propagating
//                           child: Column(
//                             children: [
//                               // Top Bar
//                               SafeArea(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(isTV ? 24 : 16),
//                                   child: Row(
//                                     children: [
//                                       isTV
//                                           ? const SizedBox.shrink()
//                                           : IconButton(
//                                               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
//                                               onPressed: () => Navigator.pop(context),
//                                             ),
//                                       Spacer(),
//                                     ],
//                                   ),
//                                 ),
//                               ),

//                               Spacer(),
//                               //CONTROLS
//                               Padding(
//                                 padding: EdgeInsets.all(isTV ? 32 : 16),
//                                 child: Column(
//                                   children: [
//                                     // Play/Pause Button and Times Row (above slider)
//                                     Row(
//                                       children: [
//                                         // Play/Pause Button (Left)
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.black.withOpacity(0.3),
//                                             shape: BoxShape.circle,
//                                             border: _isPlayPauseFocused
//                                                 ? Border.all(
//                                                     color: Colors.white,
//                                                     width: 3,
//                                                   )
//                                                 : null,
//                                           ),
//                                           child: IconButton(
//                                             icon: Icon(
//                                               state.hasEnded ? Icons.replay : (state.isPlaying ? Icons.pause : Icons.play_arrow),
//                                               color: Colors.white,
//                                               size: isTV ? 48 : 32,
//                                             ),
//                                             onPressed: () async {
//                                               if (state.hasEnded) {
//                                                 _videoPlayerBloc.add(const VideoPlayerEvent.restart());
//                                               } else {
//                                                 _videoPlayerBloc.add(const VideoPlayerEvent.togglePlayPause());
//                                               }
//                                               _controlsManager?.resetTimer();
//                                             },
//                                           ),
//                                         ),
//                                         SizedBox(width: isTV ? 24 : 16),
//                                         // Times
//                                         Text(
//                                           '${formatDuration(state.currentPosition)} / ${formatDuration(state.duration)}',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: isTV ? 18 : 14,
//                                             fontWeight: isTV ? FontWeight.w500 : FontWeight.normal,
//                                           ),
//                                         ),
//                                         Spacer(),
//                                       ],
//                                     ),

//                                     SizedBox(height: isTV ? 16 : 8),

//                                     // Progress Bar
//                                     Container(
//                                       decoration: _isSliderFocused
//                                           ? BoxDecoration(
//                                               border: Border.all(
//                                                 color: Colors.white,
//                                                 width: 2,
//                                               ),
//                                               borderRadius: BorderRadius.circular(8),
//                                             )
//                                           : null,
//                                       padding: _isSliderFocused ? EdgeInsets.all(4) : EdgeInsets.zero,
//                                       child: SliderTheme(
//                                         data: SliderTheme.of(context).copyWith(
//                                           trackHeight: isTV ? 6 : 4,
//                                           thumbShape: RoundSliderThumbShape(
//                                             enabledThumbRadius: isTV ? 12 : 8,
//                                           ),
//                                           overlayShape: RoundSliderOverlayShape(
//                                             overlayRadius: isTV ? 20 : 16,
//                                           ),
//                                         ),
//                                         child: Slider(
//                                           value: state.duration.inMilliseconds > 0 ? state.currentPosition.inMilliseconds / state.duration.inMilliseconds : 0.0,
//                                           onChanged: (value) {
//                                             if (state.duration.inMilliseconds > 0) {
//                                               final position = Duration(
//                                                 milliseconds: (value * state.duration.inMilliseconds).round(),
//                                               );
//                                               _videoPlayerBloc.add(VideoPlayerEvent.seekTo(position: position));
//                                               _controlsManager?.resetTimer();
//                                             }
//                                           },
//                                           activeColor: Colors.white,
//                                           inactiveColor: Colors.white.withOpacity(0.3),
//                                         ),
//                                       ),
//                                     ),

//                                     SizedBox(height: isTV ? 16 : 8),

//                                     // Control Buttons
//                                     Row(
//                                       mainAxisAlignment: isTV ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         // Botón de episodios (solo para series) - ahora va primero
//                                         if (type == 'series')
//                                           Container(
//                                             margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
//                                             decoration: isTV
//                                                 ? BoxDecoration(
//                                                     color: Colors.black.withOpacity(0.2),
//                                                     borderRadius: BorderRadius.circular(8),
//                                                     border: _isEpisodesFocused
//                                                         ? Border.all(
//                                                             color: Colors.white,
//                                                             width: 2,
//                                                           )
//                                                         : null,
//                                                   )
//                                                 : null,
//                                             child: Row(
//                                               children: [
//                                                 IconButton(
//                                                   icon: Icon(Icons.video_collection_outlined, color: Colors.white, size: isTV ? 40 : 32),
//                                                   onPressed: () {
//                                                     _showEpisodePanel();
//                                                     _controlsManager?.resetTimer();
//                                                   },
//                                                 ),
//                                                 Text('Episodios', style: TextStyle(color: Colors.white, fontSize: isTV ? 18 : 14)),
//                                                 SizedBox(width: isTV ? 12 : 8),
//                                               ],
//                                             ),
//                                           ),
//                                         Container(
//                                           margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
//                                           decoration: isTV
//                                               ? BoxDecoration(
//                                                   color: Colors.black.withOpacity(0.2),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   border: _isRestartFocused
//                                                       ? Border.all(
//                                                           color: Colors.white,
//                                                           width: 2,
//                                                         )
//                                                       : null,
//                                                 )
//                                               : null,
//                                           child: IconButton(
//                                             icon: Icon(Icons.replay, color: Colors.white, size: isTV ? 40 : 32),
//                                             onPressed: () async {
//                                               _videoPlayerBloc.add(const VideoPlayerEvent.restart());
//                                               _controlsManager?.resetTimer();
//                                             },
//                                           ),
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
//                                           decoration: isTV
//                                               ? BoxDecoration(
//                                                   color: Colors.black.withOpacity(0.2),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   border: _isAudioFocused
//                                                       ? Border.all(
//                                                           color: Colors.white,
//                                                           width: 2,
//                                                         )
//                                                       : null,
//                                                 )
//                                               : null,
//                                           child: IconButton(
//                                             icon: Icon(Icons.volume_up, color: Colors.white, size: isTV ? 40 : 32),
//                                             onPressed: () {
//                                               _showAudioPanel();
//                                               _controlsManager?.resetTimer();
//                                             },
//                                           ),
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
//                                           decoration: isTV
//                                               ? BoxDecoration(
//                                                   color: Colors.black.withOpacity(0.2),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   border: _isSubtitlesFocused
//                                                       ? Border.all(
//                                                           color: Colors.white,
//                                                           width: 2,
//                                                         )
//                                                       : null,
//                                                 )
//                                               : null,
//                                           child: IconButton(
//                                             icon: Icon(Icons.closed_caption, color: Colors.white, size: isTV ? 40 : 32),
//                                             onPressed: () {
//                                               _showSubtitlePanel();
//                                               _controlsManager?.resetTimer();
//                                             },
//                                           ),
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.symmetric(horizontal: isTV ? 12 : 0),
//                                           decoration: isTV
//                                               ? BoxDecoration(
//                                                   color: Colors.black.withOpacity(0.2),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   border: _isSettingsFocused
//                                                       ? Border.all(
//                                                           color: Colors.white,
//                                                           width: 2,
//                                                         )
//                                                       : null,
//                                                 )
//                                               : null,
//                                           child: IconButton(
//                                             icon: Icon(Icons.settings, color: Colors.white, size: isTV ? 40 : 32),
//                                             onPressed: () {
//                                               _showQualityPanel();
//                                               _controlsManager?.resetTimer();
//                                             },
//                                           ),
//                                         ),
//                                         if (!isTV) Spacer()
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                   // Tap to show controls - Solo si no está cargando
//                   if (_controlsManager?.showControls != true &&
//                       !state.maybeWhen(
//                         loading: (_) => true,
//                         orElse: () => false,
//                       ))
//                     GestureDetector(
//                       onTap: () {
//                         _controlsManager?.show();
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: double.infinity,
//                         color: Colors.transparent,
//                       ),
//                     ),

//                   // // Subtitle Panel
//                   // if (showSubtitlePanel)
//                   //   OptionPanel(
//                   //     key: _subtitlePanelKey,
//                   //     title: 'Subtítulos',
//                   //     isVisible: showSubtitlePanel,
//                   //     currentValue: _currentSubtitleIndex.toString(),
//                   //     options: _getSubtitleOptions(state),
//                   //     onValueChanged: (String index) {
//                   //       final selectedIndex = int.tryParse(index) ?? 0;
//                   //       final controller = state.controller ?? _videoPlayerBloc.controller;
//                   //       if (controller != null) {
//                   //         _changeSubtitleTrack(controller, selectedIndex);
//                   //       }
//                   //     },
//                   //     onClose: _hideSubtitlePanel,
//                   //   ),

//                   // // Audio Panel
//                   // if (showAudioPanel)
//                   //   OptionPanel(
//                   //     key: _audioPanelKey,
//                   //     title: 'Audio',
//                   //     isVisible: showAudioPanel,
//                   //     currentValue: _currentAudioIndex.toString(),
//                   //     options: _getAudioOptions(state),
//                   //     onValueChanged: (String index) {
//                   //       final selectedIndex = int.tryParse(index) ?? 0;
//                   //       final controller = state.controller ?? _videoPlayerBloc.controller;
//                   //       if (controller != null) {
//                   //         _changeAudioTrack(controller, selectedIndex);
//                   //       }
//                   //     },
//                   //     onClose: _hideAudioPanel,
//                   //   ),

//                   // // Quality Panel - Solo muestra opción automática
//                   // if (showQualityPanel)
//                   //   OptionPanel(
//                   //     key: _qualityPanelKey,
//                   //     title: 'Calidad',
//                   //     isVisible: showQualityPanel,
//                   //     currentValue: '0', // Siempre automática
//                   //     options: _getQualityOptions(),
//                   //     onValueChanged: (String index) {
//                   //       // No hacer nada - solo hay opción automática
//                   //     },
//                   //     onClose: _hideQualityPanel,
//                   //   ),

//                   // Episode Panel - Solo para series
//                   // if (showEpisodePanel && type == 'series')
//                   // EpisodePanel(
//                   //   key: _episodePanelKey,
//                   //   title: 'Episodios',
//                   //   isVisible: showEpisodePanel,
//                   //   currentValue: _getCurrentEpisodeValue(),
//                   //   episodes: _getEpisodeOptions(),
//                   //   onValueChanged: (String episodeNum) {
//                   //     _selectEpisode(episodeNum);
//                   //   },
//                   //   onClose: _hideEpisodePanel,
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
