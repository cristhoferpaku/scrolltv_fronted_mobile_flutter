import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';

Widget buildCardFeatureApp(
  BuildContext context,
  {
    double roundedButton = 8,
    Color colorBorder = ColorManager.background,
    double widthBorder = 1,
    Color colorBackground = ColorManager.background,
    double elevationButton = 10,
    Function? onTapCard,
    Widget child = const SizedBox.shrink(),
  }
) {

  var functionToTap = onTapCard ?? () {};

  return GestureDetector(
      onTap: () => functionToTap(), // Detecta el tap como si fuera un botón
      child: Container(
        decoration: BoxDecoration(
          color: colorBackground, // Color de fondo del "botón"
          borderRadius: BorderRadius.circular(roundedButton), // Esquinas redondeadas
          border: Border.all(
            color: colorBorder,
            width: widthBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.background.withOpacity(0.25), // Sombra similar a elevation
              offset: const Offset(2, 2), // Desplazamiento de la sombra
              blurRadius: 4, // Intensidad de la sombra
            ),
          ],
        ),
        child: child,
      ),
    );
}