import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class LiveTab extends StatefulWidget {
  const LiveTab({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {
  int selectedChannelIndex = 0;
  final isTv = PlatformUtils.isTV;

  final List<Map<String, String>> channels = [
    {'name': 'BBC NEWS', 'subtitle': 'TV-34'},
    {'name': 'ESPN', 'subtitle': 'TV-34'},
    {'name': 'CNN', 'subtitle': 'TV-34'},
    {'name': 'Ver +', 'subtitle': 'Ver más canales'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FocusTraversalGroup(
        policy: CustomGridTraversalPolicyStrictVertical(),
        child: Column(
          children: [
            // Video Player Area
            isTv ? const SizedBox(height: 140) : const SizedBox(height: 0),
            Expanded(
              flex: 3,
              child: ContainerFocus(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Channel List
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 40,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final spacing = 12.0;
                    final totalSpacing = spacing * (channels.length - 1);
                    final channelWidth = (availableWidth - totalSpacing) / channels.length;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: channels.length,
                      separatorBuilder: (context, index) => SizedBox(width: spacing),
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedChannelIndex;
                        return ContainerFocus(
                          onTap: () {
                            setState(() {
                              selectedChannelIndex = index;
                              Navigator.pushNamed(context, Routes.liveTvRoute);
                            });
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 150.r,
                            ),
                            width: channelWidth.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Channel logo/icon placeholder
                                // Channel name
                                Text(
                                  channels[index]['name']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                // Channel subtitle
                                Text(
                                  channels[index]['subtitle']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black54 : Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
