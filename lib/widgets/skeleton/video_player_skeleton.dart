import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class VideoPlayerSkeleton extends StatelessWidget {
  const VideoPlayerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTV = PlatformUtils.isTV;
    
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Fondo del reproductor con shimmer
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ShimmerAnimation(
                  shimmerGradient,
                  double.infinity,
                  double.infinity,
                  8.r,
                ),
              ),
            ),
          ),
          
          // Indicador de carga central
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF2DD4BF),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Cargando video...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Skeleton de controles inferiores
          Positioned(
            bottom: isTV ? 40 : 20,
            left: isTV ? 40 : 20,
            right: isTV ? 40 : 20,
            child: Container(
              padding: EdgeInsets.all(isTV ? 20 : 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  // Barra de progreso skeleton
                  Container(
                    height: isTV ? 8 : 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: ShimmerAnimation(
                      shimmerGradient,
                      double.infinity,
                      isTV ? 8.0 : 6.0,
                      4.r,
                    ),
                  ),
                  
                  SizedBox(height: isTV ? 16 : 12),
                  
                  // Controles skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tiempo actual skeleton
                      ShimmerAnimation(
                        shimmerGradient,
                        60.0,
                        isTV ? 20.0 : 16.0,
                        4.r,
                      ),
                      
                      // Botones centrales skeleton
                      Row(
                        children: [
                          _buildControlButtonSkeleton(isTV),
                          SizedBox(width: isTV ? 20 : 16),
                          _buildControlButtonSkeleton(isTV, isLarge: true),
                          SizedBox(width: isTV ? 20 : 16),
                          _buildControlButtonSkeleton(isTV),
                        ],
                      ),
                      
                      // Tiempo total skeleton
                      ShimmerAnimation(
                        shimmerGradient,
                        60.0,
                        isTV ? 20.0 : 16.0,
                        4.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButtonSkeleton(bool isTV, {bool isLarge = false}) {
    final size = isLarge 
        ? (isTV ? 60.0 : 48.0) 
        : (isTV ? 48.0 : 40.0);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
      ),
      child: ShimmerAnimation(
        shimmerGradient,
        size,
        size,
        size / 2,
      ),
    );
  }
}