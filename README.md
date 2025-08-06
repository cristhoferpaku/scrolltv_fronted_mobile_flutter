# 📱📺 ScrollTV Frontend Mobile Flutter

Aplicación Flutter con detección automática de plataforma para Android TV y Android Mobile.

## 🚀 Comandos de Desarrollo

### Para Android TV:
```bash
flutter run --flavor tv --dart-define=IS_TV=true
```
**O usar el script:** `.\run_tv.bat`

### Para Android Mobile:
```bash
flutter run --flavor mobile --dart-define=IS_TV=false
```
**O usar el script:** `.\run_mobile.bat`

## 📦 Generar APK Release

### Para Android TV:
```bash
flutter build apk --release --flavor tv --dart-define=IS_TV=true
```
**O usar el script:** `.\build_tv_release.bat`

### Para Android Mobile:
```bash
flutter build apk --release --flavor mobile --dart-define=IS_TV=false
```
**O usar el script:** `.\build_mobile_release.bat`

## 🔧 Detección de Plataforma

La aplicación detecta automáticamente si está ejecutándose en Android TV o Mobile usando:
- `--dart-define=IS_TV=true/false` (método principal)
- Flavors de Android (`tv` / `mobile`)
- Código en `lib/utils/platform_utils.dart`

## ⌨️ Comandos de Flutter

- `r` - Hot reload
- `R` - Hot restart  
- `h` - Listar comandos disponibles
- `d` - Detach (mantener app corriendo)
- `c` - Limpiar pantalla
- `q` - Salir (terminar aplicación)