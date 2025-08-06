import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class RoundedButton extends StatelessWidget {
  
  final String text;
  final Function press;
  final Color? color;
  final Color textColor;
  final double widthButton;

  const RoundedButton({
    this.color,
    this.textColor = Colors.white,
    required this.text,
    required this.press,
    this.widthButton = 350,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthButton,
      padding: const EdgeInsets.fromLTRB(AppPadding.p20, 10, AppPadding.p20, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: newElevatedButton(context),
      ),
    );
  }

  Widget newElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () { press(); },
      style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: Theme.of(context).textTheme.displayMedium),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}