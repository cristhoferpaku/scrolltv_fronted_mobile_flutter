import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';


class AppCardContainerShadow extends StatelessWidget {
  final Widget widget;
  final double? radius;
  final double? vertical;
  final double? horizontal;
  const AppCardContainerShadow(
      {super.key,
      required this.widget,
      this.radius,
      this.vertical,
      this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontal ?? AppPadding.p16,
            vertical: vertical ?? AppPadding.p10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget);
  }
}
