import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollToTopOnUp extends StatelessWidget {
  final Widget child;
  final double height;
  final ScrollController scrollController;

  const ScrollToTopOnUp({
    super.key,
    required this.child,
    required this.scrollController,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if ((event is KeyDownEvent || event is KeyRepeatEvent) && event.logicalKey == LogicalKeyboardKey.arrowUp) {
          final currentFocus = FocusManager.instance.primaryFocus;

          if (currentFocus != null) {
            // Intenta mover el foco hacia arriba
            bool moved = currentFocus.focusInDirection(TraversalDirection.up);

            if (moved) {
              // Espera al próximo frame para obtener el nuevo foco
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final newFocus = FocusManager.instance.primaryFocus;
                if (newFocus != null && newFocus.context != null) {
                  final renderBox = newFocus.context!.findRenderObject() as RenderBox;
                  final positionInViewport = renderBox.localToGlobal(Offset.zero).dy;
                  final positionInScroll = scrollController.offset + positionInViewport;

                  print("Nuevo foco posición: $positionInScroll");

                  if (positionInScroll < screenHeight * height) {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                }
              });
            }
          }

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
