import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class OptionPanelSkeleton extends StatelessWidget {
  final String title;
  final bool isVisible;
  final VoidCallback onClose;

  const OptionPanelSkeleton({
    Key? key,
    required this.title,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTV = PlatformUtils.isTV;
    final panelWidth = isTV ? 450.0 : 300.0;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: isVisible ? 0 : -panelWidth,
      top: 0,
      bottom: 0,
      width: panelWidth,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isTV ? 32 : 20),
              decoration: isTV ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isTV)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DD4BF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTV ? 32 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, 
                      color: Colors.white,
                      size: isTV ? 32 : 24),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            
            // Options List Skeleton
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isTV ? 24 : 16),
                itemCount: 5, // Mostrar 5 elementos skeleton
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: isTV ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(isTV ? 16 : 12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2), 
                        width: 1
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTV ? 24 : 16,
                        vertical: isTV ? 18 : 12,
                      ),
                      title: ShimmerAnimation(
                        shimmerGradient,
                        double.infinity,
                        isTV ? 22.0 : 18.0,
                        4.0,
                      ),
                      trailing: Container(
                        width: isTV ? 32 : 24,
                        height: isTV ? 32 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: isTV ? 4 : 3,
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}