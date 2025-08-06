# 📱📺 ScrollTV Frontend Mobile Flutter

Aplicación Flutter con detección automática de plataforma para Android TV y Android Mobile.

## 🔨 Generación de Código

### Instalar dependencias:
```bash
flutter pub get
```

### Generar archivos con Freezed, JSON Annotation y otros:
```bash
# Generar una sola vez
flutter packages pub run build_runner build

# Generar y eliminar archivos conflictivos automáticamente
flutter packages pub run build_runner build --delete-conflicting-outputs

# Modo watch (regenera automáticamente al detectar cambios)
flutter packages pub run build_runner watch

# Limpiar archivos generados
flutter packages pub run build_runner clean
```

### Comandos alternativos más cortos:
```bash
# Generar archivos
dart run build_runner build

# Con eliminación de conflictos
dart run build_runner build --delete-conflicting-outputs

# Modo watch
dart run build_runner watch

# Limpiar
dart run build_runner clean
```

### 📝 Archivos que se generan automáticamente:
- `*.g.dart` - Archivos de serialización JSON
- `*.freezed.dart` - Clases inmutables con Freezed
- `*.config.dart` - Configuraciones de inyección de dependencias

**⚠️ Importante:** Nunca edites manualmente los archivos `.g.dart` y `.freezed.dart`, ya que se regeneran automáticamente.

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

### Durante la ejecución (flutter run):
- `r` - Hot reload
- `R` - Hot restart  
- `h` - Listar comandos disponibles
- `d` - Detach (mantener app corriendo)
- `c` - Limpiar pantalla
- `q` - Salir (terminar aplicación)

### Comandos útiles de desarrollo:
```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Verificar dispositivos conectados
flutter devices

# Ver logs en tiempo real
flutter logs

# Inspeccionar widgets (Flutter Inspector)
flutter inspector
```

### Comandos de localización:
```bash
# Generar archivos de localización
flutter gen-l10n
```