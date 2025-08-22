import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    super.key,
    this.networkImage,
    this.image,
    required this.fit,
  });

  final String? networkImage;
  final String? image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: networkImage != null
              ? NetworkImage(networkImage ?? "")
              : AssetImage(image ?? ""),
          fit: fit,
        ),
      ),
    );
  }
}
