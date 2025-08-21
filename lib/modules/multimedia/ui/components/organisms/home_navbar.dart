import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class HomeNavbar extends StatelessWidget {
  const HomeNavbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppPadding.p16,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          ImageAssets.logoScrollTv,
          width: 100,
          height: 50,
        ),
        Row(
          spacing: AppPadding.p16,
          children: [
            ContainerFocus(
              onTap: () {},
              borderRadius: 999,
              child: SvgPicture.asset(
                ImageAssets.iconSearch,
                width: ResponsiveUtils.getIconSize(context,
                    minSize: 32, maxSize: 58),
              ),
            ),
            ContainerFocus(
              borderRadius: 999,
              child: CircleAvatar(
                radius: ResponsiveUtils.getIconSize(context,
                        minSize: 32, maxSize: 58) /
                    2,
                child: Text(
                  "D",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, Routes.profileRoute);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ContainerFocus extends StatefulWidget {
  const ContainerFocus({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<ContainerFocus> createState() => _ContainerFocusState();
}

class _ContainerFocusState extends State<ContainerFocus> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _isFocused
                ? Border.all(color: Colors.blueAccent, width: 2)
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
