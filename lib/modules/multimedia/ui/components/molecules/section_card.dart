import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';

class SectionCard extends StatefulWidget {
  final String title;
  final String coverImage;
  const SectionCard({super.key, required this.title, required this.coverImage});

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => debugPrint("Card seleccionada"),
        child: AnimatedScale(
          scale: _isFocused ? 1.08 : 1.0, // crece desde el centro
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            width: 140.r,
            height: 200.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: _isFocused
                  ? Border.all(color: Colors.blueAccent, width: 3)
                  : null,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.hardEdge,
            child: ImageWithPlaceholder(
              imageUrl: widget.coverImage,
            ),
          ),
        ),
      ),
    );
  }
}
