import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/mappers/get_channel_response_to_model.dart';

List<ChannelModel> parseM3u(String content) {
  final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
  final channels = <ChannelModel>[];

  final attrRegex = RegExp(r'([\w-]+)="([^"]+)"');

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.startsWith('#EXTINF')) {
      // Extraer atributos (tvg-name, tvg-logo, group-title, etc.)
      final attributes = <String, String>{};
      for (final match in attrRegex.allMatches(line)) {
        attributes[match.group(1)!] = match.group(2)!;
      }

      // Nombre: primero usa tvg-name si existe, si no, lo que hay después de la coma
      final commaIdx = line.indexOf(',');
      final name = attributes['tvg-name'] ?? ((commaIdx >= 0 && commaIdx < line.length - 1) ? line.substring(commaIdx + 1).trim() : 'Canal');

      // Logo
      final logo = attributes['tvg-logo'] ?? '';

      // Categoría
      final category = attributes['group-title'] ?? 'otros';

      // URL (línea siguiente)
      if (i + 1 < lines.length) {
        final urlStr = lines[i + 1].trim();
        if (!urlStr.startsWith('#')) {
          // final uri = Uri.parse(urlStr);
          channels.add(ChannelModel(
            name: name,
            url: urlStr,
            logo: logo,
            category: [category, 'todos'],
            id: generateId(),
          ));
        }
      }
    }
  }

  return channels;
}
