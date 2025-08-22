import 'package:flutter/cupertino.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

// ignore: must_be_immutable
class ResponsiveManager extends StatefulWidget {
  final Widget mobileView;
  Widget? tabletView;
  Widget? desktopView;

  ResponsiveManager({
    super.key,
    required this.mobileView,
    this.tabletView,
    this.desktopView,
  });

  @override
  State<ResponsiveManager> createState() => _ResponsiveManagerState();
}

class _ResponsiveManagerState extends State<ResponsiveManager> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= DimenReponsive.desktopDimen) {
          return widget.desktopView ?? widget.tabletView ?? widget.mobileView;
        } else if (constraints.maxWidth > DimenReponsive.tabletDimen) {
          return widget.tabletView ?? widget.desktopView ?? widget.mobileView;
        } else {
          return widget.mobileView;
        }
      },
    );
  }
}
