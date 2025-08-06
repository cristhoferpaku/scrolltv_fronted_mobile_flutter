import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/decorations/box_decoration_shadow.dart';

class ElevatedButtonApp extends StatelessWidget {
  final VoidCallback press;
  final String textButton;
  final VoidCallback longPress;
  final double heightButton;
  final Color colorButton;
  final Color colorSplash;
  final Widget? rightIconButton;
  final Widget? iconData;
  final TextStyle? textStyleButton;
  final double evelationButton;
  final double roundedButton;
  final double paddingVertical;
  final double paddingHorizontal;
  final Color colorBorder;
  final double widthBorder;
  final Alignment alignmentButton;
  final bool isExpanded;
  final bool hasShadow;

  const ElevatedButtonApp(
      {required this.press,
      required this.textButton,
      this.longPress = _emptyFunction,
      this.iconData,
      this.heightButton = AppSize.s48,
      this.colorButton = ColorManager.white,
      this.colorSplash = ColorManager.grey1,
      this.rightIconButton,
      this.textStyleButton,
      this.evelationButton = 2.0,
      this.roundedButton = 0.0,
      this.paddingHorizontal = 8.0,
      this.paddingVertical = 8.0,
      this.colorBorder = ColorManager.white,
      this.widthBorder = 0.0,
      this.alignmentButton = Alignment.center,
      this.isExpanded = true,
      this.hasShadow = false,
      super.key});

  // Función por defecto para longPress
  static void _emptyFunction() {
    debugPrint('empty');
  }

  @override
  Widget build(BuildContext context) {
    if (iconData == null) {
      final buttonApp = Container(
    decoration: hasShadow ? getBoxDecorationShadow() : null,
    child: SizedBox(
        height: heightButton,
        child: ElevatedButton(
          onPressed: press,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color?>(colorButton),
              textStyle: WidgetStateProperty.all<TextStyle?>(
                  textStyleButton ?? Theme.of(context).textTheme.headlineMedium),
              alignment: alignmentButton,
              elevation: WidgetStateProperty.all<double>(evelationButton),
              padding: WidgetStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical)),
              side: WidgetStateProperty.all<BorderSide>(BorderSide(color: colorBorder, width: widthBorder)),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(roundedButton)))),
          child: Stack(alignment: Alignment.center, children: [
            Text(textButton, style: textStyleButton, textAlign: TextAlign.center),
            Align(
                alignment: Alignment.centerRight,
                child: rightIconButton != null
                    ? Material(
                        color: ColorManager.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          onPressed: null,
                          padding: EdgeInsets.zero,
                          icon: rightIconButton!,
                        ))
                    : const SizedBox())
          ]),
        )
      )
    );
      return isExpanded ? SizedBox(width: double.infinity, child: buttonApp) : buttonApp;
    } else {
      return Container(
        height: heightButton,
        decoration: hasShadow ? getBoxDecorationShadow() : null,
        child: ElevatedButton.icon(
          onPressed: press,
          icon: iconData ?? const SizedBox.shrink(),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color?>(colorButton),
            textStyle: WidgetStateProperty.all<TextStyle?>(
                textStyleButton ?? Theme.of(context).textTheme.headlineMedium),
            alignment: alignmentButton,
            elevation: WidgetStateProperty.all<double>(evelationButton),
            padding: WidgetStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical)),
            side: WidgetStateProperty.all<BorderSide>(BorderSide(color: colorBorder, width: widthBorder)),
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(roundedButton)))),
          label: Text(textButton, style: textStyleButton),
        ));
    }
  }
}
