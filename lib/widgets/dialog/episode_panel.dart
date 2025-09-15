import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/video-player/ui/providers/video_player/video_player_bloc.dart';

import '../../modules/multimedia/domain/entities/episode_model.dart';
import '../../util/platform_utils.dart';
import '../skeleton/episodes_list_skeleton.dart';

class EpisodePanel extends StatefulWidget {
  final String title;
  final bool isVisible;
  //final String currentValue;
  //final List<EpisodeModel> episodes;
  final Function(EpisodeModel) onValueChanged;
  final VoidCallback onClose;
  final VideoPlayerBloc bloc;

  const EpisodePanel({
    super.key,
    required this.title,
    required this.isVisible,
    // required this.currentValue,
    // required this.episodes,
    required this.onValueChanged,
    required this.onClose,
    required this.bloc,
  }) : super();

  @override
  State<EpisodePanel> createState() => EpisodePanelState();
}

class EpisodePanelState extends State<EpisodePanel> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  int selectedIndex = 0;
  bool _isManuallyNavigating = false; // Flag para controlar navegación manual

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final bool isTV = PlatformUtils.isTV;
  String currentValue = '';
  List<EpisodeModel> episodes = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
      // Solicitar focus cuando el panel se hace visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isVisible) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(EpisodePanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
        // Solicitar focus cuando el panel se hace visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.isVisible) {
            _focusNode.requestFocus();
          }
        });
      } else {
        _animationController.reverse();
      }
    }
  }



  void _scrollToSelected() {
    if (_scrollController.hasClients && selectedIndex >= 0) {
      final itemWidth = isTV ? 200.0 : 120.0;
      final spacing = isTV ? 16.0 : 12.0;
      final targetOffset = selectedIndex * (itemWidth + spacing);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Solo navegar visualmente sin seleccionar
  void _navigateToIndex(int index) {
    if (index < 0 || index >= episodes.length) return;
    
    setState(() {
      selectedIndex = index;
      _isManuallyNavigating = true; // Marcar como navegación manual
    });
    
    // Scroll para asegurar que el elemento seleccionado sea visible
    if (_scrollController.hasClients) {
      double itemWidth = isTV ? 200.0 : 120.0;
      double spacing = isTV ? 16.0 : 12.0;
      double totalItemWidth = itemWidth + spacing;
      double targetOffset = index * totalItemWidth;
      
      // Calcular el viewport visible
      double viewportWidth = _scrollController.position.viewportDimension;
      double currentOffset = _scrollController.offset;
      
      // Solo hacer scroll si el item no está completamente visible
      if (targetOffset < currentOffset || 
          targetOffset + itemWidth > currentOffset + viewportWidth) {
        // Centrar el item en el viewport si es posible
        double centeredOffset = targetOffset - (viewportWidth - itemWidth) / 2;
        centeredOffset = centeredOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent
        );
        
        _scrollController.animateTo(
          centeredOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Confirmar selección del episodio actual
  void _confirmSelection() {
    if (selectedIndex >= 0 && selectedIndex < episodes.length) {
      final episode = episodes[selectedIndex];
      _isManuallyNavigating = false; // Resetear flag para permitir navegación automática
      widget.onValueChanged(episode);
      // No cerrar inmediatamente, dejar que video_page.dart maneje el cierre
      // con el delay apropiado para mostrar la selección
    }
  }



  // Método público para ser llamado desde video_page.dart
  bool handleKeyEvent(KeyEvent event) {
    if (!widget.isVisible || episodes.isEmpty) return false;
    
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          if (selectedIndex > 0) {
            _navigateToIndex(selectedIndex - 1);
            return true; // Evento manejado exitosamente
          }
          return false; // No se puede navegar más a la izquierda, permitir cerrar panel
          
        case LogicalKeyboardKey.arrowRight:
          if (selectedIndex < episodes.length - 1) {
            _navigateToIndex(selectedIndex + 1);
            return true; // Evento manejado exitosamente
          }
          return true; // Evento manejado (incluso si no se puede navegar más)
          
        case LogicalKeyboardKey.arrowUp:
          // Navegación vertical: ir al episodio anterior (como izquierda)
          if (selectedIndex > 0) {
            _navigateToIndex(selectedIndex - 1);
            return true;
          }
          return true; // Mantener el focus en el panel
          
        case LogicalKeyboardKey.arrowDown:
          // Navegación vertical: ir al siguiente episodio (como derecha)
          if (selectedIndex < episodes.length - 1) {
            _navigateToIndex(selectedIndex + 1);
            return true;
          }
          return true; // Mantener el focus en el panel
          
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          if (selectedIndex >= 0 && selectedIndex < episodes.length) {
            _confirmSelection();
          }
          return true; // Evento manejado
          
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.goBack:
          _isManuallyNavigating = false; // Resetear flag al cerrar
          widget.onClose();
          return true; // Evento manejado
      }
    }
    return false; // Evento no manejado
  }

  Widget buildPlaceholder(EpisodeModel episode, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2DD4BF).withOpacity(0.3),
            const Color(0xFF1F2937).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: Colors.white.withOpacity(0.7),
            size: isTV ? 32 : 24,
          ),
          SizedBox(height: isTV ? 8 : 4),
          Text(
            'Ep ${episode.episodeNumber}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTV ? 16 : 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (episode.description != null && episode.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTV ? 8 : 4),
              child: Text(
                episode.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTV ? 12 : 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeight = isTV ? 280.0 : 180.0;

    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        bloc: widget.bloc,
        builder: (context, state) {
          return state.maybeWhen(
              loaded: (videoUrl, controller, status, isPlaying, hasEnded, episodes, episodeIndex, showEpisodesList, isLoading, currentPosition, duration, subtitles, audioTracks, showSubtitlePanel,
                  showAudioPanel, selectedSubtitleIndex, selectedAudioIndex, currentSubtitleIndex, currentAudioIndex) {
                final isLoadingEpisodePanel = status == VideoPlayerStatus.loadingEpisodes || episodes.isEmpty;
                print('episodios cargados: ${episodes.length}, status: $status');
                this.episodes = episodes;
                
                // Solo actualizar automáticamente si no se está navegando manualmente
                if (!_isManuallyNavigating) {
                  final resolvedIndex = episodes.indexWhere((episode) => episode.episodeNumber == episodeIndex);
                  final calculatedSelectedIndex = resolvedIndex != -1 ? resolvedIndex : 0;
                  
                  // Solo actualizar selectedIndex si es diferente
                  if (selectedIndex != calculatedSelectedIndex) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedIndex = calculatedSelectedIndex;
                        });
                        _scrollToSelected();
                      }
                    });
                  }
                }
                return AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 0,
                      right: 0,
                      bottom: _slideAnimation.value * panelHeight,
                      height: panelHeight,
                      child: Focus(
                        focusNode: _focusNode,
                        autofocus: false, // Controlar el focus manualmente
                        onKeyEvent: (node, event) {
                          bool handled = handleKeyEvent(event);
                          return handled ? KeyEventResult.handled : KeyEventResult.ignored;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.95),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Container(
                                padding: EdgeInsets.all(isTV ? 24 : 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (isTV)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2DD4BF),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        Text(
                                          widget.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTV ? 28 : 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.white, size: isTV ? 28 : 20),
                                      onPressed: widget.onClose,
                                    ),
                                  ],
                                ),
                              ),

                              // Episodes List

                              Expanded(
                                child: isLoadingEpisodePanel
                                    ? const EpisodesListSkeleton()
                                    : ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(horizontal: isTV ? 24 : 16),
                                        itemCount: episodes.length,
                                        itemBuilder: (context, index) {
                                          final isSelected = index == selectedIndex;
                                          final episode = episodes[index];
                                          final itemWidth = isTV ? 200.0 : 120.0;
                                          final itemHeight = isTV ? 120.0 : 80.0;

                                          return Container(
                                            width: itemWidth,
                                            margin: EdgeInsets.only(
                                              right: isTV ? 16 : 12,
                                              bottom: isTV ? 16 : 12,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                _navigateToIndex(index);
                                                _confirmSelection();
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(isTV ? 12 : 8),
                                                  border: isSelected ? Border.all(color: const Color(0xFF2DD4BF), width: isTV ? 4 : 3) : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                                            blurRadius: isTV ? 15 : 8,
                                                            spreadRadius: isTV ? 2 : 1,
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(isTV ? 12 : 8),
                                                  child: Stack(
                                                    children: [
                                                      // Episode Cover Image
                                                      SizedBox(
                                                        width: itemWidth,
                                                        height: itemHeight,
                                                        child: episode.coverImage != null && episode.coverImage!.isNotEmpty
                                                            ? Image.network(
                                                                episode.coverImage!,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return buildPlaceholder(episode, itemWidth, itemHeight);
                                                                },
                                                                loadingBuilder: (context, child, loadingProgress) {
                                                                  if (loadingProgress == null) return child;
                                                                  return buildPlaceholder(episode, itemWidth, itemHeight);
                                                                },
                                                              )
                                                            : buildPlaceholder(episode, itemWidth, itemHeight),
                                                      ),

                                                      // Episode Number Overlay
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: isTV ? 8 : 6,
                                                            vertical: isTV ? 4 : 2,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.8),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            'Ep ${episode.episodeNumber}',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: isTV ? 14 : 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // Selected Indicator
                                                      if (isSelected)
                                                        Positioned(
                                                          bottom: 8,
                                                          right: 8,
                                                          child: Container(
                                                            width: isTV ? 24 : 16,
                                                            height: isTV ? 24 : 16,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF2DD4BF),
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                                                  blurRadius: 4,
                                                                  spreadRadius: 1,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Icon(
                                                              Icons.check,
                                                              color: Colors.white,
                                                              size: isTV ? 16 : 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              orElse: () => const Center(
                    child: CircularProgressIndicator(),
                  ));
        });
  }
}
