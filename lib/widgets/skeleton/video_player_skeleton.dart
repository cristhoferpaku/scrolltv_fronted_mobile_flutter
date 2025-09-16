import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/shimmer/shimmer_util.dart';

class VideoPlayerSkeleton extends StatefulWidget {
  const VideoPlayerSkeleton({super.key});

  @override
  State<VideoPlayerSkeleton> createState() => _VideoPlayerSkeletonState();
}

class _VideoPlayerSkeletonState extends State<VideoPlayerSkeleton> {
  String _loadingMessage = 'Inicializando reproductor...';
  int _loadingTime = 0;
  Timer? _messageTimer;
  Timer? _timeTimer;

  @override
  void initState() {
    super.initState();
    _startLoadingMessages();
  }

  @override
  void didUpdateWidget(VideoPlayerSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reiniciar timers cuando el widget se actualiza (nuevo episodio)
    _resetTimers();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _timeTimer?.cancel();
    super.dispose();
  }

  void _resetTimers() {
    // Cancelar timers existentes
    _messageTimer?.cancel();
    _timeTimer?.cancel();
    
    // Reiniciar valores
    _loadingTime = 0;
    _loadingMessage = 'Inicializando reproductor...';
    
    // Reiniciar timers
    _startLoadingMessages();
  }

  void _startLoadingMessages() {
    // Timer para actualizar el tiempo transcurrido
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _loadingTime++;
        });
      }
    });

    // Timer para cambiar los mensajes de carga
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          switch (timer.tick % 4) {
            case 0:
              _loadingMessage = 'Conectando con el servidor...';
              break;
            case 1:
              _loadingMessage = 'Cargando contenido de video...';
              break;
            case 2:
              _loadingMessage = 'Preparando reproductor...';
              break;
            case 3:
              _loadingMessage = 'Casi listo...';
              break;
          }
        });
      }
    });
  }

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: const Color(0xFF2DD4BF),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  _loadingMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_loadingTime > 5)
                  Text(
                    'Tiempo transcurrido: ${_loadingTime}s',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                if (_loadingTime > 15)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Si la carga toma mucho tiempo,\nverifique su conexión a internet',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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