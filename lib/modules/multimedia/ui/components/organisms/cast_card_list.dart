import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/cast_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/cast_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class CastCardList extends StatefulWidget {
  final List<CastModel> casts;
  final bool disabledEnsureVisible;
  const CastCardList({
    super.key,
    required this.casts,
    this.disabledEnsureVisible = false,
  });

  @override
  State<CastCardList> createState() => _CastCardListState();
}

class _CastCardListState extends State<CastCardList> {
  int lastfocusindex = 0;

  FocusNode focusNode = FocusNode();
  List<FocusNode> focusNodes = [];
  @override
  Widget build(BuildContext context) {
    if (focusNodes.isEmpty || focusNodes.length != widget.casts.length) {
      focusNodes = List.generate(widget.casts.length, (index) => FocusNode());
    }
    return FocusTraversalGroup(
      policy: CustomGridSectionHorizontal(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: AppPadding.p12.r,
        children: [
          Text("Reparto", style: Theme.of(context).textTheme.titleLarge),
          if (widget.casts.isEmpty)
            NoContentBox()
          else
            Focus(
              focusNode: focusNode,
              canRequestFocus: false,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  FocusScope.of(context).requestFocus(focusNodes[lastfocusindex]);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!widget.disabledEnsureVisible) {
                      Scrollable.ensureVisible(focusNode.context!, alignment: 0.5, duration: const Duration(milliseconds: 200));
                    }
                  });
                }
              },
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent || event is KeyRepeatEvent) {
                  if (focusNodes.first.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    return KeyEventResult.handled;
                  }
                  if (focusNodes.last.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                }
                return KeyEventResult.ignored;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: AppPadding.p24.r,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    widget.casts.length,
                    (index) => Focus(
                        canRequestFocus: false,
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (hasFocus) {
                                lastfocusindex = index;
                              }
                            });
                          }
                        },
                        child: CastCard(cast: widget.casts[index], focusNode: focusNodes[index])),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
