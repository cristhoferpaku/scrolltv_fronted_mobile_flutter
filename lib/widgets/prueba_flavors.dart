import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class PruebaFlavors extends StatelessWidget {
  const PruebaFlavors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono y texto de la plataforma
              Icon(
                PlatformUtils.isTV ? Icons.tv : Icons.phone_android,
                size: 80,
                color: PlatformUtils.isTV ? Colors.blue : Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                PlatformUtils.isTV ? 'Android TV' : 'Android Mobile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: PlatformUtils.isTV ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Plataforma detectada correctamente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
  }
}