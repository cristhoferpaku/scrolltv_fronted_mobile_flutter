import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/platform_utils.dart';

class EpisodePanel extends StatefulWidget {
  final String title;
  final bool isVisible;
  final String currentValue;
  final List<Map<String, dynamic>> episodes;
  final Function(String) onValueChanged;
  final VoidCallback onClose;

  const EpisodePanel({
    super.key,
    required this.title,
    required this.isVisible,
    required this.currentValue,
    required this.episodes,
    required this.onValueChanged,
    required this.onClose,
  });

  @override
  State<EpisodePanel> createState() => _EpisodePanelState();
}

class _EpisodePanelState extends State<EpisodePanel> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final bool isTV = PlatformUtils.isTV;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _updateSelectedIndex();

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(EpisodePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _updateSelectedIndex();
    }
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _updateSelectedIndex() {
    final currentEpisodeNumber = int.tryParse(widget.currentValue) ?? 1;
    selectedIndex = widget.episodes.indexWhere(
      (episode) => episode['episodeNumber'] == currentEpisodeNumber,
    );
    if (selectedIndex == -1) selectedIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
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
    if (index >= 0 && index < widget.episodes.length) {
      setState(() {
        selectedIndex = index;
      });
      _scrollToSelected();
    }
  }

  // Confirmar selección del episodio actual
  void _confirmSelection() {
    if (selectedIndex >= 0 && selectedIndex < widget.episodes.length) {
      final episode = widget.episodes[selectedIndex];
      widget.onValueChanged(episode['episodeNumber'].toString());
      widget.onClose();
    }
  }

  // Método público para ser llamado desde video_page.dart
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (selectedIndex > 0) {
          _navigateToIndex(selectedIndex - 1);
          return true; // Evento manejado exitosamente
        }
        return false; // No se puede navegar más a la izquierda, permitir cerrar panel
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (selectedIndex < widget.episodes.length - 1) {
          _navigateToIndex(selectedIndex + 1);
        }
        return true; // Evento manejado (incluso si no se puede navegar más)
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
        _confirmSelection();
        return true; // Evento manejado
      } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.goBack) {
        widget.onClose();
        return true; // Evento manejado
      }
    }
    return false; // Evento no manejado
  }



  @override
  Widget build(BuildContext context) {
    final panelHeight = isTV ? 280.0 : 180.0;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: _slideAnimation.value * panelHeight,
          height: panelHeight,
          child: Focus(
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
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
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isTV ? 24 : 16),
                      itemCount: widget.episodes.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIndex;
                        final episode = widget.episodes[index];
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
                                      child: episode['coverImage'] != null && episode['coverImage'].isNotEmpty
                                          ? Image.network(
                                              episode['coverImage'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildPlaceholder(episode, itemWidth, itemHeight);
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return _buildPlaceholder(episode, itemWidth, itemHeight);
                                              },
                                            )
                                          : _buildPlaceholder(episode, itemWidth, itemHeight),
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
                                          'Ep ${episode['episodeNumber']}',
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
  }

  Widget _buildPlaceholder(Map<String, dynamic> episode, double width, double height) {
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
            'Ep ${episode['episodeNumber']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTV ? 16 : 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (episode['title'] != null && episode['title'].isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTV ? 8 : 4),
              child: Text(
                episode['title'],
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
    _animationController.dispose();
    super.dispose();
  }
}
