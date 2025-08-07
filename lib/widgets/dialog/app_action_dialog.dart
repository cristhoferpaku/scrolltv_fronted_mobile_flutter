import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/font_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class AppActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const AppActionDialog({
    super.key,
    required this.title,
    required this.description,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      insetPadding: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const Divider(
              color: ColorManager.primary,
            ).withPadding(vertical: AppPadding.p8),
            // Descripción
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            // Botón Principal (si existe)
            if (primaryButtonText != null && onPrimaryButtonPressed != null)
              ElevatedButton(
                onPressed: onPrimaryButtonPressed,
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(primaryButtonText!,
                    style: getRegularStyle(
                        color: ColorManager.white, fontsize: FontSize.s16)),
              ),
            if (primaryButtonText != null && onPrimaryButtonPressed != null)
              const SizedBox(height: 12.0),
            // Botón Secundario (si existe)
            if (secondaryButtonText != null && onSecondaryButtonPressed != null)
              OutlinedButton(
                onPressed: onSecondaryButtonPressed,
                style: Theme.of(context).outlinedButtonTheme.style,
                child: Text(secondaryButtonText!,
                    style: getRegularStyle(
                        color: ColorManager.primary, fontsize: FontSize.s16)),
              ),
          ],
        ),
      ),
    );
  }
}
