import 'package:flutter/material.dart';

class NoContentBox extends StatelessWidget {
  final double? height;
  const NoContentBox({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(child: Text("No hay contenido")),
    );
  }
}
