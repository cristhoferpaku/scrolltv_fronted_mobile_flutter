# 📱📺 Detección de Plataforma - ScrollTV

## 🚀 Comandos Rápidos

### Para Android TV:
```bash
flutter run --flavor tv --dart-define=IS_TV=true
```
**O usar el script:**
- Windows: `.\run_tv.bat` o `.\run_tv.ps1`

### Para Android Mobile:
```bash
flutter run --flavor mobile --dart-define=IS_TV=false
```
**O usar el script:**
- Windows: `.\run_mobile.bat` o `.\run_mobile.ps1`

## 🔧 Cómo Funciona

La detección de plataforma utiliza múltiples estrategias:

1. **Dart Define**: `--dart-define=IS_TV=true/false` (principal)
2. **Flavor Detection**: Detecta automáticamente el flavor `tv`
3. **Fallback**: Por defecto asume mobile

## 📋 Archivos Importantes

- `lib/utils/platform_utils.dart` - Lógica de detección
- `android/app/build.gradle` - Configuración de flavors
- `run_tv.bat` / `run_mobile.bat` - Scripts de ejecución

## 🎯 Uso en Código

```dart
import 'package:your_app/utils/platform_utils.dart';

// Verificar plataforma
if (PlatformUtils.isTV) {
  // Lógica para Android TV
} else if (PlatformUtils.isMobile) {
  // Lógica para Android Mobile
}

// Obtener tipo como string
String platform = PlatformUtils.platformType; // 'tv' o 'mobile'

// Debug info
Map<String, String> debug = PlatformUtils.debugInfo;
```

## ✅ Ventajas

- ✅ **Simple**: Solo requiere un parámetro adicional
- ✅ **Confiable**: No depende de heurísticas complejas
- ✅ **Rápido**: Detección sincrónica
- ✅ **Mantenible**: Código limpio y claro
- ✅ **Flexible**: Funciona con dart-define o flavors