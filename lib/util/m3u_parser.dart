import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/mappers/get_channel_response_to_model.dart';

/// Parseo simple de M3U (EXTM3U + pares #EXTINF / URL)
List<ChannelModel> parseM3u(String content) {
  final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
  final channels = <ChannelModel>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('#EXTINF')) {
      // Nombre después de la coma
      final commaIdx = line.indexOf(',');
      final name = (commaIdx >= 0 && commaIdx < line.length - 1) ? line.substring(commaIdx + 1).trim() : 'Canal';

      // La siguiente línea debería ser la URL
      if (i + 1 < lines.length) {
        final urlStr = lines[i + 1].trim();
        if (!urlStr.startsWith('#')) {
          final uri = Uri.parse(urlStr);
          channels.add(ChannelModel(name: name, url: uri, logo: '', category: ['todos'], id: generateId()));
        }
      }
    }
  }
  return channels;
}
