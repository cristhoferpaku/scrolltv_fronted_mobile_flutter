import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';

class ChannelCard extends StatefulWidget {
  const ChannelCard({
    super.key,
    required this.tvPlayerBloc,
    required this.channel,
    this.focusNode,
  });

  final TvPlayerBloc tvPlayerBloc;
  final ChannelModel channel;
  final FocusNode? focusNode;

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
      autofocus: isSelected,
      focusNode: widget.focusNode,
      onTap: () {
        tvPlayerBloc.add(TvPlayerEvent.changeChannel(widget.channel));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF2DD4BF), width: 2) : null,
        ),
        child: ListTile(
          onTap: () {
            tvPlayerBloc.add(TvPlayerEvent.changeChannel(widget.channel));
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.tv,
                color: isSelected ? Colors.black : Colors.white,
                size: 24,
              ),
            ),
          ),
          title: Text(
            widget.channel.name,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // subtitle: Text(
          //   widget.channel.category.join(', '),
          //   style: TextStyle(
          //     color: widget.isSelected ? const Color(0xFF2DD4BF).withOpacity(0.8) : Colors.grey[400],
          //     fontSize: 14,
          //   ),
          // ),
          trailing: isSelected
              ? const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF2DD4BF),
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }
}
