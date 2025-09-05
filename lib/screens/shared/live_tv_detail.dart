import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';

class LiveTvDetail extends StatefulWidget {
  const LiveTvDetail({super.key});

  @override
  State<LiveTvDetail> createState() => _LiveTvDetailState();
}

class _LiveTvDetailState extends State<LiveTvDetail> {
  final livePlayerBloc = instance<TvPlayerBloc>();
  bool showChannelList = false;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Variables para el desplazamiento continuo
  bool _isScrollingUp = false;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      livePlayerBloc.add(TvPlayerEvent.started());
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _scrollToSelectedChannel() {
  //   if (_scrollController.hasClients) {
  //     const itemHeight = 80.0; // Altura aproximada de cada item
  //     final viewportHeight = _scrollController.position.viewportDimension;
  //     final maxScrollExtent = _scrollController.position.maxScrollExtent;

  //     // Calcular la posición para centrar el elemento seleccionado
  //     // Centrar significa que el elemento esté en el medio de la pantalla
  //     final targetOffset = (1 * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);

  //     // Asegurar que el offset esté dentro de los límites válidos
  //     final clampedOffset = targetOffset.clamp(0.0, maxScrollExtent);

  //     // Siempre hacer scroll para centrar el elemento
  //     _scrollController.animateTo(
  //       clampedOffset,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  // void _changeChannel(int channelIndex) {
  //   setState(() {
  //     selectedChannelIndex = channelIndex;
  //   });

  //   // Mostrar confirmación del cambio de canal
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Cambiando a: ${channels[channelIndex]['name']}'),
  //       duration: const Duration(seconds: 2),
  //       backgroundColor: const Color(0xFF2DD4BF),
  //     ),
  //   );
  // }

  // void _startContinuousScroll(bool isUp) {
  //   if (isUp) {
  //     _isScrollingUp = true;
  //     _continuousScrollUp();
  //   } else {
  //     _isScrollingDown = true;
  //     _continuousScrollDown();
  //   }
  // }

  // void _continuousScrollUp() async {
  //   while (_isScrollingUp && showChannelList) {
  //     if (selectedChannelIndex > 0) {
  //       setState(() {
  //         selectedChannelIndex--;
  //       });
  //       _scrollToSelectedChannel();
  //       await Future.delayed(const Duration(milliseconds: 150));
  //     } else {
  //       break;
  //     }
  //   }
  // }

  // void _continuousScrollDown() async {
  //   while (_isScrollingDown && showChannelList) {
  //     if (selectedChannelIndex < channels.length - 1) {
  //       setState(() {
  //         selectedChannelIndex++;
  //       });
  //       _scrollToSelectedChannel();
  //       await Future.delayed(const Duration(milliseconds: 150));
  //     } else {
  //       break;
  //     }
  //   }
  // }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          if (!showChannelList) {
            setState(() {
              showChannelList = true;
            });
          }
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (showChannelList) {
            setState(() {
              showChannelList = false;
            });
          } else {
            Navigator.pop(context);
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          if (showChannelList && !_isScrollingUp) {
            // _startContinuousScroll(true);
          }
          break;
        case LogicalKeyboardKey.arrowDown:
          if (showChannelList && !_isScrollingDown) {
            // _startContinuousScroll(false);
          }
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          if (showChannelList) {
            // Cambiar al canal seleccionado
            // _changeChannel(selectedChannelIndex);
            // Cerrar la lista de canales
            setState(() {
              showChannelList = false;
            });
          }
          break;
      }
    } else if (event is KeyUpEvent) {
      // Detener el desplazamiento continuo cuando se suelta la tecla
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _isScrollingUp = false;
          break;
        case LogicalKeyboardKey.arrowDown:
          _isScrollingDown = false;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<TvPlayerBloc, TvPlayerState>(
        bloc: livePlayerBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: Stack(
              children: [
                // Video Player Area
                Column(
                  children: [
                    Expanded(child: ChannelView(channels: state.channels, selectedChannelIndex: state.selectedChannelIndex)),
                    Expanded(child: ChannelList(scrollController: _scrollController, channels: state.channels, selectedChannelIndex: state.selectedChannelIndex)),
                  ],
                ),

                // Channel List Overlay
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: showChannelList ? 0 : -400,
                  top: 0,
                  bottom: 0,
                  width: 400,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Channel List
                        Expanded(
                          child: ChannelList(scrollController: _scrollController, channels: state.channels, selectedChannelIndex: state.selectedChannelIndex),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChannelList extends StatefulWidget {
  const ChannelList({
    super.key,
    required ScrollController scrollController,
    required this.channels,
    required this.selectedChannelIndex,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Map<String, String>> channels;
  final int selectedChannelIndex;

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget._scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.channels.length,
      itemBuilder: (context, index) {
        final isSelected = index == widget.selectedChannelIndex;
        final channel = widget.channels[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: const Color(0xFF2DD4BF), width: 2) : null,
          ),
          child: ListTile(
            onTap: () {
              tvPlayerBloc.add(TvPlayerEvent.changeChannel(index));
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.tv,
                  color: isSelected ? Colors.black : Colors.white,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              channel['name']!,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              channel['subtitle']!,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.8) : Colors.grey[400],
                fontSize: 14,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF2DD4BF),
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class ChannelView extends StatefulWidget {
  const ChannelView({
    super.key,
    required this.channels,
    required this.selectedChannelIndex,
  });

  final List<Map<String, String>> channels;
  final int selectedChannelIndex;

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 120,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),
            Text(
              widget.channels.isNotEmpty && widget.selectedChannelIndex < widget.channels.length ? widget.channels[widget.selectedChannelIndex]['name']! : 'Sin canal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.channels.isNotEmpty && widget.selectedChannelIndex < widget.channels.length ? widget.channels[widget.selectedChannelIndex]['subtitle']! : 'No hay información disponible',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
