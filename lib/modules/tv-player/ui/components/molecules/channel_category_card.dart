import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class ChannelCategoryCard extends StatefulWidget {
  final int index;
  final bool isSelected;
  final FocusNode? focusNode;
  final ChannelCategoryModel category;
  const ChannelCategoryCard({
    required this.focusNode,
    super.key,
    required this.isSelected,
    required this.index,
    required this.category,
  });

  @override
  State<ChannelCategoryCard> createState() => _ChannelCategoryCardState();
}

class _ChannelCategoryCardState extends State<ChannelCategoryCard> {
  final TvPlayerBloc livePlayerBloc = instance<TvPlayerBloc>();

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      focusNode: widget.focusNode,
      onTap: () {
        livePlayerBloc.add(TvPlayerEvent.changeCategory(widget.index));
      },
      child: ExcludeFocus(
        child: ElevatedButtonApp(
          press: () {},
          textButton: widget.category.name,
          isExpanded: false,
          textStyleButton: Theme.of(context).textTheme.labelLarge,
          colorButton: widget.isSelected ? ColorManager.primaryContainer : Colors.transparent,
        ),
      ),
    );
  }
}
