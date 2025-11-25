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

moviehome

```bash
flutter run --flavor moviehomeTv --dart-define=IS_TV=true --dart-define=VARIANT=moviehome
```

scrolltv

```bash
flutter run --flavor scrolltvTv --dart-define=IS_TV=true --dart-define=VARIANT=scrolltv
```

**O usar el script:** `.\run_tv.bat`

### Para Android Mobile:

moviehome

```bash
flutter run --flavor moviehomeMobile --dart-define=IS_TV=false --dart-define=VARIANT=moviehome
```

scrolltv

```bash
flutter run --flavor scrolltvMobile --dart-define=IS_TV=false --dart-define=VARIANT=scrolltv
```

**O usar el script:** `.\run_mobile.bat`

## 📦 Generar APK Release

### Para Android TV:

moviehome

moviehome

```bash
flutter build apk --release --flavor moviehomeTv --dart-define=IS_TV=true --dart-define=VARIANT=moviehome
```

scrolltv

```bash
flutter build apk --release --flavor scrolltvTv --dart-define=IS_TV=true --dart-define=VARIANT=scrolltv
```

**O usar el script:** `.\build_tv_release.bat`

### Para Android Mobile:

moviehome

```bash
flutter build apk --release --flavor moviehomeMobile --dart-define=IS_TV=false --dart-define=VARIANT=moviehome
```

scrolltv

```bash
flutter build apk --release --flavor scrolltvMobile --dart-define=IS_TV=false --dart-define=VARIANT=scrolltv
```

**O usar el script:** `.\build_mobile_release.bat`

## 🔧 Detección de Plataforma

La aplicación detecta automáticamente si está ejecutándose en Android TV o Mobile usando:

- `--dart-define=IS_TV=true/false` (método principal)
- `--dart-define=VARIANT=moviehome/scrolltv` (método secundario)
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

### Comandos de splash:

moviehome

```bash
flutter pub run flutter_native_splash:create --path=flutter_native_splash_movie_home.yaml
```

scrolltv

```bash
flutter pub run flutter_native_splash:create --path=flutter_native_splash_scroll_tv.yaml

```

### Comandos de iconos:

moviehome

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons_movie_home.yaml
```

scrolltv

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons_scroll_tv.yaml

```

###

Generar apk ScrollTV:

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons_scroll_tv.yaml
```

```bash
flutter pub run flutter_native_splash:create --path=flutter_native_splash_scroll_tv.yaml
```

```bash
flutter build apk --release --flavor scrolltvMobile --dart-define=IS_TV=false --dart-define=VARIANT=scrolltv
```

```bash
flutter build apk --release --flavor scrolltvTv --dart-define=IS_TV=true --dart-define=VARIANT=scrolltv
```

subir al drive de releases

subir apk de tv a bunnynet - storage - scroll-tv-movie-home-storage - apks - copiar url

Generar apk MovieHome:

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons_movie_home.yaml
```

splash

```bash
flutter pub run flutter_native_splash:create --path=flutter_native_splash_movie_home.yaml
```

```bash
flutter build apk --release --flavor moviehomeMobile --dart-define=IS_TV=false --dart-define=VARIANT=moviehome

```

```bash
flutter build apk --release --flavor moviehomeTv --dart-define=IS_TV=true --dart-define=VARIANT=moviehome


```

subir al drive de releases

subir apk de tv a bunnynet - storage - scroll-tv-movie-home-storage - apks - copiar url
