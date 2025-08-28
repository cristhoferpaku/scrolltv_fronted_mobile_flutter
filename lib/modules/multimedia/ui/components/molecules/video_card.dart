import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';

class VideoCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String coverImage;
  final FocusNode? focusNode;

  const VideoCard({
    super.key,
    required this.title,
    required this.coverImage,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      focusNode: focusNode,
      onTap: onTap,
      child: Container(
        width: 140.r,
        height: 200.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: ImageWithPlaceholder(
          imageUrl: coverImage,
        ),
      ),
    );
  }
}
