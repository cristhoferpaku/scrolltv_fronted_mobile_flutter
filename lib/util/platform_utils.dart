import 'package:flutter/foundation.dart';
import 'dart:io';

class PlatformUtils {
  /// Método simple: Detecta si estamos en Android TV usando múltiples estrategias
  static bool get isTV {
    if (kIsWeb) return false;
    if (!Platform.isAndroid) return false;
    
    // Estrategia 1: Verificar si se definió IS_TV=true en dart-define
    const isDefinedTV = bool.fromEnvironment('IS_TV', defaultValue: false);
    if (isDefinedTV) return true;
    
    // Estrategia 2: Verificar el flavor directamente
    const flavor = String.fromEnvironment('FLUTTER_FLAVOR', defaultValue: '');
    if (flavor == 'tv') return true;
    
    // Estrategia 3: Verificar si el flavor está en el nombre del paquete o build
    // Esto funciona porque el flavor 'tv' genera un APK con nombre diferente
    const appName = String.fromEnvironment('FLUTTER_APP_NAME', defaultValue: '');
    if (appName.contains('tv')) return true;
    
    // Por defecto, asumir mobile si no se puede determinar
    return false;
  }

  /// Detecta si estamos en Android Mobile
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid && !isTV;
  }
  
  /// Método alternativo: Detecta la plataforma como String para mayor claridad
  static String get platformType {
    if (kIsWeb) return 'web';
    if (!Platform.isAndroid) return 'other';
    
    return isTV ? 'tv' : 'mobile';
  }
  
  /// Método de debug para ver todas las variables de entorno
  static Map<String, String> get debugInfo {
    return {
      'IS_TV': const String.fromEnvironment('IS_TV', defaultValue: 'not_set'),
      'FLUTTER_FLAVOR': const String.fromEnvironment('FLUTTER_FLAVOR', defaultValue: 'not_set'),
      'FLUTTER_APP_NAME': const String.fromEnvironment('FLUTTER_APP_NAME', defaultValue: 'not_set'),
      'Platform': Platform.operatingSystem,
      'isAndroid': Platform.isAndroid.toString(),
      'isTV_result': isTV.toString(),
    };
  }
}