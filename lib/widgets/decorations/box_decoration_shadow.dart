import 'package:flutter/material.dart';

BoxDecoration getBoxDecorationShadow({double borderRadius = 10.0, double opacity = 0.9, double blurValue = 3 }) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, opacity),
          blurRadius: blurValue,
          offset: const Offset(4, 4),
        ),
      ],
  );
}