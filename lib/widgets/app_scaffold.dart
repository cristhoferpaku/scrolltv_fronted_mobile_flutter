import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color? color;
  final String? backgroundImage;
  final LinearGradient? linearGradient;
  final double padding;

  const AppScaffold(
      {super.key,
      required this.body,
      this.color = ColorManager.surfaceContainerLowest,
      this.backgroundImage,
      this.linearGradient,
      this.padding = AppPadding.p16});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null)
              Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            if (linearGradient != null)
              Container(
                decoration: BoxDecoration(
                  gradient: linearGradient!,
                ),
              ),
            Align(
              alignment: Alignment.topLeft,
              child: body.withPadding(horizontal: padding),
            ),
          ],
        ),
      ),
    );
  }
}
