import 'package:flutter/material.dart';

void showAppDialog(
    {required BuildContext context,
    required Widget appDialog,
    bool isDimissigle = true}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) =>
        _buildTransition(context, anim1, anim2, appDialog),
    transitionDuration: const Duration(milliseconds: 300),
    barrierDismissible: isDimissigle,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
}

Widget _buildTransition(BuildContext context, Animation<double> anim1,
    Animation<double> anim2, Widget appDialog) {
  final entryCurve = Curves.easeInOut.transform(anim1.value); // Entrada suave
  final exitCurve =
      Curves.easeInOut.transform(1.0 - anim2.value); // Salida suave
  return Transform.scale(
    scale: entryCurve,
    child: Opacity(
      opacity: anim1.value * exitCurve,
      child: appDialog,
    ),
  );
}
