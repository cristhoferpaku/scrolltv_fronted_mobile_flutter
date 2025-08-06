import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class AppElevatedButton extends StatelessWidget {

  final Function press;
  final Color colorButton;
  final Color colorSplash;
  final String pathImage;
  final double sizeImage;

  const AppElevatedButton({
    required this.press,
    this.colorButton = ColorManager.white,
    this.colorSplash = ColorManager.grey1,
    required this.pathImage,
    this.sizeImage = 36,
    super.key
  
  });

  @override
  Widget build(BuildContext context) {
    return 
      ElevatedButton(
        onPressed: () {press;},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: AppEdgeInsets.all(10),
          foregroundColor: colorButton, // <-- Button color
          disabledBackgroundColor: colorSplash, // <-- Splash color
        ),
        child: Image(
            width: sizeImage, 
            height: sizeImage,
            image: AssetImage(pathImage),
            fit: BoxFit.fitWidth,
        ),
      );
  }
}