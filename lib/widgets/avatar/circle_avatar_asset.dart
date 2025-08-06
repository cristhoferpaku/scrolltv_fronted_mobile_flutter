import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:flutter/material.dart';

class CircleAvatarAsset extends StatelessWidget {

  final String pathAsset;
  final String networkAsset;
  final double radiusAvatar;
  final double radiusBorder;

  const CircleAvatarAsset({
    super.key,
    required this.pathAsset,
    this.networkAsset = '',
    this.radiusAvatar = 30,
    this.radiusBorder = 1
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: ColorManager.primary,
      radius: radiusAvatar + radiusBorder,
      child: CircleAvatar(
        radius: radiusAvatar,
        backgroundImage: _getImageProvider(),
      ),
    );
  }

  ImageProvider<Object>? _getImageProvider() {
    if (networkAsset.isNotEmpty) {
      return NetworkImage(networkAsset);
    } else {
      return AssetImage(pathAsset);
    }
  }
}