import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/text_drop_shadow.dart';

class TopCard extends StatefulWidget {
  final String title;
  final int topNumber;
  final String coverImage;
  final int videoId;
  const TopCard({
    super.key,
    required this.title,
    required this.topNumber,
    required this.coverImage,
    required this.videoId,
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
        onTap: () => {Navigator.pushNamed(context, Routes.videoDetailsRoute, arguments: VideoDetailsPageArguments(videoId: widget.videoId))},
        child: AnimatedScale(
          scale: _isFocused ? 1.08 : 1.0, // crece desde el centro
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: _isFocused ? Border.all(color: Colors.blueAccent, width: 3) : null,
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
                          fontSize: 163.r,
                        ),
                      ),
                      Container(
                        width: 140.r,
                        height: 200.r,
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
