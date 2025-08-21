import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/text_drop_shadow.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/responsive_utils.dart';

class TopCard extends StatefulWidget {
  final String title;
  final int topNumber;
  final String coverImage;
  const TopCard({
    super.key,
    required this.title,
    required this.topNumber,
    required this.coverImage,
  });

  @override
  State<TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Transform.translate(
                        offset: const Offset(30, 0),
                        child: TextDropShadow(
                          text: widget.topNumber.toString(),
                          fontSize: ResponsiveUtils.getSize(context,
                              minSize: 163, maxSize: 300),
                        ),
                      ),
                      Container(
                        width: ResponsiveUtils.getSize(context,
                            minSize: 150, maxSize: 280),
                        height: ResponsiveUtils.getSize(context,
                            minSize: 175, maxSize: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ImageWithPlaceholder(
                          imageUrl: widget.coverImage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
