import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/image_with_placeholder.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';

class ChannelCard extends StatefulWidget {
  const ChannelCard({
    super.key,
    required this.tvPlayerBloc,
    required this.channel,
    this.focusNode,
    required this.index,
  });

  final TvPlayerBloc tvPlayerBloc;
  final ChannelModel channel;
  final FocusNode? focusNode;
  final int index;

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = tvPlayerBloc.state.selectedChannelIndex?.id == widget.channel.id;
    return ContainerFocus(
      focusNode: widget.focusNode,
      onTap: () {
        tvPlayerBloc.add(TvPlayerEvent.changeChannel(widget.channel));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ColorManager.primaryContainer.withValues(alpha: 1),
                    ColorManager.primaryContainer.withValues(alpha: 1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [
                    ColorManager.primaryContainer.withOpacity(0.3),
                    ColorManager.primaryContainer.withOpacity(0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 80.r,
          child: Row(spacing: 16.r, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(widget.index.toString()),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: ImageWithPlaceholder(
                width: 60.r,
                height: 40.r,
                imageUrl: widget.channel.logo,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Text(
                widget.channel.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
