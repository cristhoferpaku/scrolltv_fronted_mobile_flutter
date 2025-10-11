import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_card.dart';

class SectionCard extends StatefulWidget {
  final String title;
  final String coverImage;
  final Function()? onTap;
  final FocusNode? focusNode;

  const SectionCard({super.key, required this.title, required this.coverImage, this.onTap, this.focusNode});

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  @override
  Widget build(BuildContext context) {
    return VideoCard(
      focusNode: widget.focusNode,
      title: widget.title,
      coverImage: widget.coverImage,
      onTap: widget.onTap,
    );
  }
}
