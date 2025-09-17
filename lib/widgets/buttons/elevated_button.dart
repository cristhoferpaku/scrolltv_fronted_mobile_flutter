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
  final bool enabled;
  final Size minimumSize;
  final FocusNode? focusNode;
  final bool autofocus;

  const ElevatedButtonApp(
      {required this.press,
      required this.textButton,
      this.longPress = _emptyFunction,
      this.iconData,
      this.heightButton = AppSize.s48,
      this.colorButton = ColorManager.primary,
      this.colorSplash = ColorManager.grey1,
      this.rightIconButton,
      this.textStyleButton,
      this.evelationButton = 2.0,
      this.roundedButton = 12.0,
      this.paddingHorizontal = 24.0,
      this.paddingVertical = 8.0,
      this.colorBorder = ColorManager.transparent,
      this.widthBorder = 0.0,
      this.alignmentButton = Alignment.center,
      this.isExpanded = true,
      this.hasShadow = false,
      this.enabled = true,
      this.minimumSize = Size.zero,
      this.focusNode,
      this.autofocus = false,
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
              child: ElevatedButton(
            focusNode: focusNode,
            autofocus: autofocus,
            onPressed: enabled ? press : null,
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color?>(colorButton),
                textStyle: WidgetStateProperty.all<TextStyle?>(textStyleButton ?? Theme.of(context).textTheme.titleSmall),
                alignment: alignmentButton,
                elevation: WidgetStateProperty.all<double>(evelationButton),
                padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical)),
                minimumSize: WidgetStateProperty.all<Size>(minimumSize),
                side: WidgetStateProperty.all<BorderSide>(BorderSide(color: colorBorder, width: widthBorder)),
                shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(roundedButton)))),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Ajuste al contenido
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text(textButton, style: textStyleButton, textAlign: TextAlign.center)),
                if (rightIconButton != null) ...[
                  const SizedBox(width: 8),
                  rightIconButton!,
                ],
              ],
            ),
          )));
      return isExpanded ? SizedBox(width: double.infinity, child: buttonApp) : IntrinsicWidth(child: buttonApp);
    } else {
      return IntrinsicWidth(
        child: Container(
            decoration: hasShadow ? getBoxDecorationShadow() : null,
            child: ElevatedButton.icon(
              onPressed: enabled ? press : null,
              icon: iconData ?? const SizedBox.shrink(),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color?>(colorButton),
                  textStyle: WidgetStateProperty.all<TextStyle?>(textStyleButton ?? Theme.of(context).textTheme.headlineMedium),
                  alignment: alignmentButton,
                  elevation: WidgetStateProperty.all<double>(evelationButton),
                  padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical)),
                  side: WidgetStateProperty.all<BorderSide>(BorderSide(color: colorBorder, width: widthBorder)),
                  shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(roundedButton)))),
              label: Center(child: Text(textButton, style: textStyleButton)),
            )),
      );
    }
  }
}
