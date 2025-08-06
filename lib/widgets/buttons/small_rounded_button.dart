import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class SmallRoundedButton extends StatelessWidget {
  
  final String text;
  final Function press;
  final Color? color;
  final bool isExpanded;

  const SmallRoundedButton({
    this.color,
    required this.text,
    required this.press,
    this.isExpanded = false, 
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.s8),
      child: newElevatedButton(context),
    );

    // Si se desea expandir (para disposición horizontal), lo envolvemos en `Expanded`
    if (isExpanded) {
      return Expanded(child: button);
    } else {
      return button;
    }
  }

  Widget newElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () { press(); },
      style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p10),
          textStyle: Theme.of(context).textTheme.headlineSmall),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}