import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollToTopOnUp extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;

  const ScrollToTopOnUp({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 3;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (scrollController.hasClients &&
              scrollController.offset > 0 &&
              scrollController.offset <= screenHeight) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            print("Scroll to top");
            return KeyEventResult.ignored; // no consumir el evento
          }

          return KeyEventResult.ignored;
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
