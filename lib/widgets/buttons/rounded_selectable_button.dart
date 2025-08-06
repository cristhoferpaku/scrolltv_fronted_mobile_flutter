
import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';

Widget roundedSelectableButton(
  BuildContext context,
  Function press,
  String textButton,
  Color colorBorder,
  bool isActive,
  {
    Color inactive = ColorManager.backgroundLight
  }
  ) {
  return ElevatedButton(
    onPressed: () {
      press();
    },
    style: ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(width: 1, color: colorBorder)
        ),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(isActive ? colorBorder : inactive)
    ),
    child: Text(
      textButton,
      style: Theme.of(context).textTheme.bodyMedium),
  );
          
}