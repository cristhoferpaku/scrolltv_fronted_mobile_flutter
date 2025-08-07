import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/constants/data/colors_data.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/components/molecules/color_card.dart';

class ColorCardList extends StatelessWidget {
  final List<ColorData> colors;
  const ColorCardList({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: colors
          .map((color) => ColorCard(color: color.color, name: color.name))
          .toList(),
    );
  }
}
