// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/enum_widgets.dart';

class AppInfoDialog extends StatelessWidget {
  final String title;
  final List<InfoItem> items;
  final VoidCallback? onButtonPressed;
  final String? buttonText;

  const AppInfoDialog({
    super.key,
    required this.title,
    required this.items,
    this.onButtonPressed,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      insetPadding: const EdgeInsets.all(20.0),
      elevation: 10,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ],
                ),
                const Divider(color: ColorManager.primary),
                // Lista de Íconos y Títulos
                ..._buildItemsWithDividers(context),
                // Botón Inferior Opcional
                if (buttonText != null && onButtonPressed != null)
                  ElevatedButton(
                    onPressed: onButtonPressed,
                    child: Text(buttonText!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsWithDividers(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      widgets.add(_buildInfoItem(context, items[i]));
      if (i < items.length - 1) {
        widgets.add(const Divider());
      }
    }

    return widgets;
  }

  Widget _buildInfoItem(BuildContext context, InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildIcon(item.iconPath, item.iconType),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String? iconPath, TypeImageAsset? iconType) {
    if (iconPath == null || iconType == null) {
      return const SizedBox.shrink();
    }

    switch (iconType) {
      case TypeImageAsset.IMAGE:
        return Image.asset(iconPath, width: 24.0, height: 24.0);
      case TypeImageAsset.SVG:
        return SvgPicture.asset(iconPath, width: 24.0, height: 24.0);
      case TypeImageAsset.JSON:
        return Lottie.asset(iconPath, width: 24.0, height: 24.0);
    }
  }
}

class InfoItem {
  final String? iconPath;
  final TypeImageAsset? iconType;
  final String text;

  InfoItem({
    required this.text,
    this.iconPath,
    this.iconType,
  });
}
