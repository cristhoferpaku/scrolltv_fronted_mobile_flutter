import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';

class TextDropShadow extends StatelessWidget {
  const TextDropShadow({
    super.key,
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sombra difusa (drop shadow)
        Text(
          text,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: fontSize,
            color: Colors.transparent, // no pintamos el texto
            shadows: [
              Shadow(
                offset: const Offset(0, 0), // hacia dónde cae la sombra
                color: ColorManager.primary300.withValues(alpha: 0.5),
                blurRadius: 40,
              ),
            ],
          ),
        ),
        // Borde del texto
        Text(
          text,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: fontSize,
                foreground: Paint()
                  ..color = ColorManager.primary
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4,
              ),
        ),
        // Relleno interior
        Text(
          text,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: fontSize,
                color: ColorManager.surfaceContainerLowest, // color interior
              ),
        ),
      ],
    );
  }
}
