import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/components/molecules/channel_category_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart' show TvPlayerBloc;
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';

class ChannelCategoryList extends StatefulWidget {
  final int selectedCategoryIndex;
  final List<ChannelCategoryModel> categories;
  final List<FocusNode> focusNodes;
  const ChannelCategoryList({super.key, required this.selectedCategoryIndex, required this.categories, required this.focusNodes});

  @override
  State<ChannelCategoryList> createState() => _ChannelCategoryListState();
}

class _ChannelCategoryListState extends State<ChannelCategoryList> {
  final TvPlayerBloc livePlayerBloc = instance<TvPlayerBloc>();

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          // Bloquear primer y último nodo vertical
          if (widget.focusNodes.first.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowUp) {
            return KeyEventResult.handled;
          }
          if (widget.focusNodes.last.hasFocus && event.logicalKey == LogicalKeyboardKey.arrowDown) {
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: ColorManager.neutro900,
        child: ListView.separated(
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return ChannelCategoryCard(
              index: index,
              isSelected: index == widget.selectedCategoryIndex,
              focusNode: widget.focusNodes[index],
              category: widget.categories[index],
            );
          },
        ),
      ),
    );
  }
}
