import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

// HLS Quality Variant class
class HlsVariant {
  final String url;        // URL completa de la variante
  final String? resolution; // 1280x720
  final int? bandwidth;    // BANDWIDTH aprox bps
  final double? frameRate; // FRAME-RATE
  final String name;       // Nombre para mostrar (ej: "720p")

  HlsVariant({
    required this.url, 
    this.resolution, 
    this.bandwidth, 
    this.frameRate,
    required this.name
  });
}

class VideoControllerManager {
  VlcPlayerController? _vlcPlayerController;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _hasEnded = false;
  VoidCallback? _onStateChanged;
  String? _videoUrl;
  String? _currentSubtitle;
  
  // HLS stream options
  List<Map<String, String>> _subtitleTracks = [];
  List<Map<String, String>> _audioTracks = [];
  List<Map<String, String>> _qualityLevels = [];
  int _currentSubtitleIndex = -1;
  int _currentAudioIndex = 0;
  int _currentQualityIndex = 0;
  
  // HLS Quality variants
  List<HlsVariant> _hlsVariants = [];
  String? _masterPlaylistUrl;
  bool _isLiveStream = false;
  
  // Quality change debounce
  bool _isChangingQuality = false;
  
  // Audio/Subtitle track mapping from master playlist
  List<Map<String, String>> _masterAudioTracks = [];
  List<Map<String, String>> _masterSubtitleTracks = [];

  // Getters
  VlcPlayerController? get controller => _vlcPlayerController;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get hasEnded => _hasEnded;
  String? get currentSubtitle => _currentSubtitle;
  List<Map<String, String>> get subtitleTracks => _subtitleTracks;
  List<Map<String, String>> get audioTracks => _audioTracks;
  List<Map<String, String>> get qualityLevels => _qualityLevels;
  int get currentSubtitleIndex => _currentSubtitleIndex;
  int get currentAudioIndex => _currentAudioIndex;
  int get currentQualityIndex => _currentQualityIndex;
  List<HlsVariant> get hlsVariants => _hlsVariants;
  bool get isLiveStream => _isLiveStream;

  // Parse HLS variants from master playlist
  Future<List<HlsVariant>> _fetchHlsVariants(String masterUrl) async {
    try {
      final res = await http.get(Uri.parse(masterUrl));
      if (res.statusCode != 200) {
        throw Exception('No se pudo descargar master.m3u8');
      }
      
      final lines = const LineSplitter().convert(res.body);
      final List<HlsVariant> variants = [];
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('#EXT-X-STREAM-INF')) {
          // Extrae atributos
          String? resolution;
          int? bandwidth;
          double? frameRate;
          
          final attrs = line.substring(line.indexOf(':') + 1).split(',');
          for (final attr in attrs) {
            final kv = attr.split('=');
            if (kv.length != 2) continue;
            final key = kv[0].trim();
            final val = kv[1].trim().replaceAll('"', '');
            if (key == 'RESOLUTION') resolution = val;
            if (key == 'BANDWIDTH') bandwidth = int.tryParse(val);
            if (key == 'FRAME-RATE') frameRate = double.tryParse(val);
          }
          
          // La siguiente línea debe ser la URI de la variante
          if (i + 1 < lines.length) {
            final uriLine = lines[i + 1].trim();
            final fullUrl = _resolveUrl(masterUrl, uriLine);
            
            // Generar nombre basado en resolución
            String name = 'Auto';
            if (resolution != null) {
              final parts = resolution.split('x');
              if (parts.length == 2) {
                final height = parts[1];
                name = '${height}p';
              }
            } else if (bandwidth != null) {
              // Fallback basado en bandwidth
              if (bandwidth < 1000000) name = '480p';
              else if (bandwidth < 3000000) name = '720p';
              else name = '1080p';
            }
            
            variants.add(HlsVariant(
              url: fullUrl,
              resolution: resolution,
              bandwidth: bandwidth,
              frameRate: frameRate,
              name: name,
            ));
          }
        }
      }
      
      return variants;
    } catch (e) {
      print('Error parsing HLS variants: $e');
      return [];
    }
  }
  
  // Resolve relative URLs
  String _resolveUrl(String masterUrl, String uri) {
    final master = Uri.parse(masterUrl);
    final u = Uri.parse(uri);
    if (u.hasScheme) return u.toString(); // absoluta
    // relativa → resolver contra master
    return master.resolveUri(u).toString();
  }
  
  // Robust quality change using --preferred-resolution with master playlist
  Future<void> _reloadWithPreferredResolution({
    required String masterUrl,
    required int? preferredHeight, // 240/480/720/1080 o null (Auto)
    required bool isLive,
    required VlcPlayerController controller,
    required bool wasPlaying,
    Duration? currentPos,
    int? currentVolume,
    Map<String, String>? currentAudioTrack,
    Map<String, String>? currentSubtitleTrack,
  }) async {
    await controller.stop();
    await Future.delayed(const Duration(milliseconds: 150));

    // Since setMediaFromNetwork doesn't accept options, we need to recreate the controller
    // with preferred resolution options if needed
    if (preferredHeight != null && preferredHeight > 0) {
      print('Note: VLC preferred-resolution requires controller recreation, using setMediaFromNetwork for now');
    }

    await controller.setMediaFromNetwork(masterUrl);

    // Wait for VLC to populate track lists
    await Future.delayed(const Duration(milliseconds: 250));
    
    // Wait for media to be ready
    int attempts = 0;
    while (attempts < 8) {
      try {
        final audioTracks = await controller.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          print('Media ready after quality change');
          break;
        }
      } catch (e) {
        print('Waiting for media to be ready... attempt ${attempts + 1}');
      }
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    // Restore audio track by language/name matching
    if (currentAudioTrack != null) {
      await Future.delayed(const Duration(milliseconds: 150));
      try {
        final newAudioTracks = await controller.getAudioTracks();
        print('Available audio tracks: $newAudioTracks');
        
        MapEntry<int, String>? matchingAudio;
        
        // Try language match first (if available)
        if (currentAudioTrack.containsKey('language') && currentAudioTrack['language'] != 'unknown') {
          for (final entry in newAudioTracks.entries) {
            if (entry.value.toLowerCase().contains(currentAudioTrack['language']!.toLowerCase())) {
              matchingAudio = entry;
              print('Audio matched by language: ${currentAudioTrack['language']}');
              break;
            }
          }
        }
        
        // Fallback to name matching
        if (matchingAudio == null && currentAudioTrack.containsKey('name')) {
          for (final entry in newAudioTracks.entries) {
            if (entry.value.toLowerCase().contains(currentAudioTrack['name']!.toLowerCase()) ||
                currentAudioTrack['name']!.toLowerCase().contains(entry.value.toLowerCase())) {
              matchingAudio = entry;
              print('Audio matched by name: ${currentAudioTrack['name']}');
              break;
            }
          }
        }
        
        if (matchingAudio != null) {
          await controller.setAudioTrack(matchingAudio.key);
          print('Audio track restored: ${matchingAudio.value}');
        }
      } catch (e) {
        print('Error restoring audio track: $e');
      }
    }

    // Restore subtitle track by language/name matching
    if (currentSubtitleTrack != null) {
      await Future.delayed(const Duration(milliseconds: 150));
      try {
        final newSpuTracks = await controller.getSpuTracks();
        print('Available subtitle tracks: $newSpuTracks');
        
        MapEntry<int, String>? matchingSpu;
        
        // Try language match first (if available)
        if (currentSubtitleTrack.containsKey('language') && currentSubtitleTrack['language'] != 'unknown') {
          for (final entry in newSpuTracks.entries) {
            if (entry.value.toLowerCase().contains(currentSubtitleTrack['language']!.toLowerCase())) {
              matchingSpu = entry;
              print('Subtitle matched by language: ${currentSubtitleTrack['language']}');
              break;
            }
          }
        }
        
        // Fallback to name matching
        if (matchingSpu == null && currentSubtitleTrack.containsKey('name')) {
          for (final entry in newSpuTracks.entries) {
            if (entry.value.toLowerCase().contains(currentSubtitleTrack['name']!.toLowerCase()) ||
                currentSubtitleTrack['name']!.toLowerCase().contains(entry.value.toLowerCase())) {
              matchingSpu = entry;
              print('Subtitle matched by name: ${currentSubtitleTrack['name']}');
              break;
            }
          }
        }
        
        if (matchingSpu != null) {
          await controller.setSpuTrack(matchingSpu.key);
          print('Subtitle track restored: ${matchingSpu.value}');
        }
      } catch (e) {
        print('Error restoring subtitle track: $e');
      }
    }

    // Restore volume (always re-apply as some builds reset it)
    if (currentVolume != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        await controller.setVolume(currentVolume);
        print('Volume restored to: $currentVolume');
      } catch (e) {
        print('Could not restore volume: $e');
      }
    }

    // Start playback if it was playing before
    if (wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      await controller.play();
      print('Playback resumed');
    }

    // Restore position (only for VOD, not live)
    if (!isLive && currentPos != null && currentPos.inMilliseconds > 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        await controller.seekTo(currentPos);
        print('Position restored to: ${currentPos.inSeconds}s');
      } catch (e) {
        print('Could not restore position: $e');
        // Retry once more
        await Future.delayed(const Duration(milliseconds: 400));
        try {
          await controller.seekTo(currentPos);
          print('Position restored on retry: ${currentPos.inSeconds}s');
        } catch (e2) {
          print('Could not restore position on retry: $e2');
        }
      }
    }
  }

  // Initialize player with URL
  void initializePlayer(String videoUrl, {VoidCallback? onStateChanged}) {
    _onStateChanged = onStateChanged;
    _videoUrl = videoUrl;
    _masterPlaylistUrl = videoUrl;
    
    _vlcPlayerController = VlcPlayerController.network(
      videoUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    
    _vlcPlayerController!.addOnInitListener(() async {
      await _vlcPlayerController!.startRendererScanning();
    });
    
    _vlcPlayerController!.addOnRendererEventListener((type, id, name) {
      print('OnRendererEventListener $type $id $name');
    });
    
    _vlcPlayerController!.addListener(() {
      _isPlaying = _vlcPlayerController!.value.isPlaying;
      _currentPosition = _vlcPlayerController!.value.position;
      _totalDuration = _vlcPlayerController!.value.duration;
      
      // Check if video has ended (only set to true, don't reset to false here)
      if (_totalDuration.inMilliseconds > 0 && 
          _currentPosition.inMilliseconds >= _totalDuration.inMilliseconds - 1000) {
        if (!_hasEnded) {
          print('Video has ended - setting _hasEnded to true');
          _hasEnded = true;
        }
      }
      
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    });
    
    // Load HLS stream options after initialization
    _loadHLSOptions();
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (_vlcPlayerController != null) {
      if (_hasEnded) {
        // If video has ended, restart from beginning using robust method
        print('Restarting video from replay button');
        await _restartVideo();
        _hasEnded = false;
      } else if (_isPlaying) {
        _vlcPlayerController!.pause();
      } else {
        _vlcPlayerController!.play();
        // Reset ended state when playing normally
        if (_currentPosition.inMilliseconds < _totalDuration.inMilliseconds - 1000) {
          if (_hasEnded) {
            print('Resetting _hasEnded to false - playing normally');
            _hasEnded = false;
          }
        }
      }
    }
  }

  // Seek to position
  void seekTo(Duration position) {
    if (_vlcPlayerController != null) {
      _vlcPlayerController!.seekTo(position);
      // Reset ended state when seeking
      if (position.inMilliseconds < _totalDuration.inMilliseconds - 1000) {
        _hasEnded = false;
      }
    }
  }

  // Skip backward
  void skipBackward(int seconds) {
    if (_vlcPlayerController != null) {
      final newPosition = _currentPosition - Duration(seconds: seconds);
      _vlcPlayerController!.seekTo(newPosition);
      // Reset ended state when skipping
      if (newPosition.inMilliseconds < _totalDuration.inMilliseconds - 1000) {
        _hasEnded = false;
      }
    }
  }

  // Skip forward
  void skipForward(int seconds) {
    if (_vlcPlayerController != null) {
      final newPosition = _currentPosition + Duration(seconds: seconds);
      _vlcPlayerController!.seekTo(newPosition);
      // Reset ended state when skipping
      if (newPosition.inMilliseconds < _totalDuration.inMilliseconds - 1000) {
        _hasEnded = false;
      }
    }
  }

  // Restart video
  Future<void> restart() async {
    await _restartVideo();
    _hasEnded = false;
  }

  // Format duration for display
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  // Robust restart method for VLC player
  Future<void> _restartVideo() async {
    if (_vlcPlayerController != null && _videoUrl != null) {
      try {
        // Stop the player to release internal state
        await _vlcPlayerController!.stop();
        
        // Wait a bit for VLC to fully stop
        await Future.delayed(const Duration(milliseconds: 150));
        
        // Re-load the media from network
        await _vlcPlayerController!.setMediaFromNetwork(_videoUrl!);
        
        // Start playing after loading
        await _vlcPlayerController!.play();
      } catch (e) {
        print('Error restarting video: $e');
      }
    }
  }

  // Load HLS stream options
  Future<void> _loadHLSOptions() async {
    if (_vlcPlayerController == null) return;
    
    try {
      // Wait for player to be ready
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Clear existing options
      _subtitleTracks.clear();
      _audioTracks.clear();
      _masterAudioTracks.clear();
      _masterSubtitleTracks.clear();
      
      // Parse master playlist for LANGUAGE/NAME mapping
      if (_masterPlaylistUrl != null) {
        await _parseMasterPlaylistTracks(_masterPlaylistUrl!);
      }
      
      // Try to get real subtitle tracks from VLC
       try {
         final spuCount = await _vlcPlayerController!.getSpuTracks();
         print('=== REAL HLS DATA FROM VLC ===');
         print('Real SPU tracks count: ${spuCount.length}');
         
         // Add "Desactivados" option first
         _subtitleTracks.add({
           'id': '-1',
           'name': 'Desactivados',
           'language': 'none'
         });
         
         if (spuCount.isNotEmpty) {
           // Add real subtitle tracks (VLC doesn't provide description method)
           spuCount.forEach((key, value) {
             print('Found subtitle track $key: $value');
             _subtitleTracks.add({
               'id': key.toString(),
               'name': value,
               'language': 'unknown'
             });
           });
         } else {
           print('No hay subtítulos disponibles en este HLS');
         }
       } catch (e) {
         print('Error getting SPU tracks: $e');
         print('No se pudieron obtener los subtítulos del HLS');
         // Add only "Desactivados" option
         _subtitleTracks.add({
           'id': '-1',
           'name': 'Desactivados',
           'language': 'none'
         });
       }
      
      // Try to get real audio tracks from VLC
       try {
        // final audioCount = await _vlcPlayerController!.getAudioTracksCount();
         final audio = await _vlcPlayerController!.getAudioTracks();
         print('Real audio tracks count: ${audio.length}');
         
         _audioTracks.clear();
         if (audio.isNotEmpty) {
           // Add real audio tracks with their actual names from VLC
           audio.forEach((key, value) {
             print('Found audio track $key: $value');
             _audioTracks.add({
               'id': key.toString(),
               'name': value,
               'language': 'unknown'
             });
           });
         
         } else {
           print('No hay pistas de audio disponibles en este HLS');
           // Add default audio track
           _audioTracks.add({
             'id': '0',
             'name': 'Audio Principal',
             'language': 'unknown'
           });
         }
       } catch (e) {
         print('Error getting audio tracks: $e');
         print('No se pudieron obtener las pistas de audio del HLS');
         // Add default audio track
         _audioTracks.add({
           'id': '0',
           'name': 'Audio Principal',
           'language': 'unknown'
         });
       }
      
      // Parse HLS quality variants from master playlist
      print('=== PARSING HLS QUALITY VARIANTS ===');
      _qualityLevels.clear();
      _hlsVariants.clear();
      
      try {
        if (_masterPlaylistUrl != null) {
          _hlsVariants = await _fetchHlsVariants(_masterPlaylistUrl!);
          print('Found ${_hlsVariants.length} HLS variants');
          
          // Always add Auto option first
          _qualityLevels.add({
            'id': '0', 
            'name': 'Auto (Adaptativo)', 
            'resolution': 'auto',
            'url': _masterPlaylistUrl!
          });
          
          // Add detected quality variants
          for (int i = 0; i < _hlsVariants.length; i++) {
            final variant = _hlsVariants[i];
            _qualityLevels.add({
              'id': (i + 1).toString(),
              'name': variant.name,
              'resolution': variant.resolution ?? 'unknown',
              'url': variant.url,
              'bandwidth': variant.bandwidth?.toString() ?? '0'
            });
            print('Added quality: ${variant.name} (${variant.resolution}) - ${variant.bandwidth} bps');
          }
          
          print('Total quality options: ${_qualityLevels.length}');
        } else {
          print('No master playlist URL available');
          _qualityLevels.add({
            'id': '0', 
            'name': 'Auto', 
            'resolution': 'auto',
            'url': _videoUrl ?? ''
          });
        }
        
      } catch (e) {
        print('Error parsing HLS quality variants: $e');
        // Fallback to Auto only
        _qualityLevels = [
          {'id': '0', 'name': 'Auto', 'resolution': 'auto', 'url': _videoUrl ?? ''},
        ];
      }
      
      print('=== FINAL LOADED OPTIONS ===');
      print('Subtitles: ${_subtitleTracks.length}');
      for (int i = 0; i < _subtitleTracks.length; i++) {
        print('  [$i] ${_subtitleTracks[i]}');
      }
      
      print('Audio tracks: ${_audioTracks.length}');
      for (int i = 0; i < _audioTracks.length; i++) {
        print('  [$i] ${_audioTracks[i]}');
      }
      
      print('Quality levels: ${_qualityLevels.length}');
      for (int i = 0; i < _qualityLevels.length; i++) {
        print('  [$i] ${_qualityLevels[i]}');
      }
      print('=== END HLS OPTIONS ===');
      
      // Sync current audio index with what's actually playing
      await _syncCurrentAudioIndex();
      
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      print('Error loading HLS options: $e');
    }
  }
  
  // Change subtitle track
  Future<void> changeSubtitleTrack(int index) async {
    if (_vlcPlayerController == null || index >= _subtitleTracks.length) return;
    
    _currentSubtitleIndex = index;
    
    try {
      if (index == 0) {
        // Disable subtitles
        await _vlcPlayerController!.setSpuTrack(-1);
        _currentSubtitle = null;
      } else {
        // Enable subtitle track
        final trackId = int.tryParse(_subtitleTracks[index]['id'] ?? '0') ?? 0;
        await _vlcPlayerController!.setSpuTrack(trackId);
        _currentSubtitle = _subtitleTracks[index]['name'];
      }
      
      print('Subtitle changed to: ${_subtitleTracks[index]['name']}');
      
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      print('Error changing subtitle: $e');
    }
  }
  
  // Change audio track
  // Sync current audio index with VLC's actual playing track
  Future<void> _syncCurrentAudioIndex() async {
    if (_vlcPlayerController == null || _audioTracks.isEmpty) return;
    
    try {
      final currentTrackId = await _vlcPlayerController!.getAudioTrack();
      print('Current playing track ID from VLC: $currentTrackId');
      
      // Find the index that matches the current track ID
      for (int i = 0; i < _audioTracks.length; i++) {
        final trackId = int.tryParse(_audioTracks[i]['id'] ?? '0') ?? 0;
        if (trackId == currentTrackId) {
          _currentAudioIndex = i;
          print('Synced current audio index to: $i (${_audioTracks[i]['name']})');
          break;
        }
      }
    } catch (e) {
      print('Error syncing current audio index: $e');
    }
  }

  Future<void> changeAudioTrack(int index) async {
    if (_vlcPlayerController == null || index >= _audioTracks.length) return;

    
    try {
      // Store the desired track name before rebuilding the list
      final desiredTrackName = _audioTracks[index]['name'];
      // Get current audio tracks from VLC to get the real IDs
      final currentTracks = await _vlcPlayerController!.getAudioTracks();
      
      if (currentTracks.isEmpty) {

        return;
      }
      
      // Find the track ID that matches the desired track name
      int? targetTrackId;
      for (final entry in currentTracks.entries) {
        if (entry.value == desiredTrackName) {
          targetTrackId = entry.key;
          break;
        }
      }
      
      if (targetTrackId == null) {
        print('Could not find track with name: $desiredTrackName');
        return;
      }
      
      print('Found target track ID: $targetTrackId for name: $desiredTrackName');
      
      // Set the audio track using the found ID
      await _vlcPlayerController!.setAudioTrack(targetTrackId);
      
      // Update our stored tracks with the current VLC track IDs
      final availableIds = currentTracks.keys.toList();
      final availableNames = currentTracks.values.toList();
      
      // Sync our stored tracks with current VLC tracks
      _audioTracks.clear();
      for (int i = 0; i < availableIds.length; i++) {
        _audioTracks.add({
          'id': availableIds[i].toString(),
          'name': availableNames[i],
          'language': 'unknown'
        });
      }
      
      print('Updated audio tracks: $_audioTracks');
      
      // Sync the current index with what's actually playing
      await _syncCurrentAudioIndex();
      
      print('Successfully changed audio to: ${_audioTracks[_currentAudioIndex]['name']}');
      
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      print('Error changing audio: $e');
      print('Stack trace: ${e.toString()}');
    }
  }
  
  // Helper method to create track key for matching by language/name
  Map<String, String> _createTrackKey(Map<String, String> track) {
    return {
      'language': (track['language'] ?? '').toLowerCase(),
      'name': (track['name'] ?? '').toLowerCase(),
    };
  }
  
  // Parse master playlist to extract LANGUAGE/NAME mapping for audio and subtitle tracks
  Future<void> _parseMasterPlaylistTracks(String masterUrl) async {
    try {
      print('=== PARSING MASTER PLAYLIST FOR TRACK MAPPING ===');
      final response = await http.get(Uri.parse(masterUrl));
      if (response.statusCode == 200) {
        final content = response.body;
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          
          // Parse audio tracks: #EXT-X-MEDIA:TYPE=AUDIO
          if (line.startsWith('#EXT-X-MEDIA:TYPE=AUDIO')) {
            final audioTrack = _parseMediaLine(line);
            if (audioTrack.isNotEmpty) {
              _masterAudioTracks.add(audioTrack);
              print('Found master audio track: ${audioTrack['name']} (${audioTrack['language']})');
            }
          }
          
          // Parse subtitle tracks: #EXT-X-MEDIA:TYPE=SUBTITLES
          if (line.startsWith('#EXT-X-MEDIA:TYPE=SUBTITLES')) {
            final subtitleTrack = _parseMediaLine(line);
            if (subtitleTrack.isNotEmpty) {
              _masterSubtitleTracks.add(subtitleTrack);
              print('Found master subtitle track: ${subtitleTrack['name']} (${subtitleTrack['language']})');
            }
          }
        }
        
        print('Master playlist parsing completed: ${_masterAudioTracks.length} audio, ${_masterSubtitleTracks.length} subtitle tracks');
      } else {
        print('Failed to fetch master playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing master playlist tracks: $e');
    }
  }
  
  // Parse a #EXT-X-MEDIA line to extract track information
  Map<String, String> _parseMediaLine(String line) {
    final track = <String, String>{};
    
    try {
      // Extract GROUP-ID
      final groupIdMatch = RegExp(r'GROUP-ID="([^"]+)"').firstMatch(line);
      if (groupIdMatch != null) {
        track['groupId'] = groupIdMatch.group(1) ?? '';
      }
      
      // Extract LANGUAGE
      final languageMatch = RegExp(r'LANGUAGE="([^"]+)"').firstMatch(line);
      if (languageMatch != null) {
        track['language'] = languageMatch.group(1) ?? '';
      }
      
      // Extract NAME
      final nameMatch = RegExp(r'NAME="([^"]+)"').firstMatch(line);
      if (nameMatch != null) {
        track['name'] = nameMatch.group(1) ?? '';
      }
      
      // Extract URI (optional)
      final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(line);
      if (uriMatch != null) {
        track['uri'] = uriMatch.group(1) ?? '';
      }
      
      // Extract DEFAULT
      final defaultMatch = RegExp(r'DEFAULT=(YES|NO)').firstMatch(line);
      if (defaultMatch != null) {
        track['default'] = defaultMatch.group(1) ?? 'NO';
      }
      
      // Extract AUTOSELECT
      final autoselectMatch = RegExp(r'AUTOSELECT=(YES|NO)').firstMatch(line);
      if (autoselectMatch != null) {
        track['autoselect'] = autoselectMatch.group(1) ?? 'NO';
      }
      
    } catch (e) {
      print('Error parsing media line: $e');
    }
    
    return track;
  }

  // Robust quality change using master playlist + preferred-resolution
  Future<void> changeQualityLevel(int index) async {
    // Debounce: prevent simultaneous quality changes
    if (_isChangingQuality) {
      print('Quality change already in progress, ignoring request');
      return;
    }
    
    if (_vlcPlayerController == null || index >= _qualityLevels.length) {
      print('Cannot change quality: controller or quality levels not available');
      return;
    }

    _isChangingQuality = true;
    print('Changing quality to index: $index');
    
    try {
      // 1) Save current state
      bool? wasPlaying;
      Duration? currentPos;
      int? currentVolume;
      String? currentAudioLanguage;
      String? currentAudioName;
      String? currentSubLanguage;
      String? currentSubName;
      bool subtitlesDisabled = false;
      
      try {
        wasPlaying = await _vlcPlayerController!.isPlaying();
        print('Was playing: $wasPlaying');
      } catch (e) {
        print('Could not get playing state: $e');
        wasPlaying = false;
      }
      
      if (!_isLiveStream) {
        try {
          currentPos = await _vlcPlayerController!.getPosition();
          print('Current position: ${currentPos?.inSeconds}s');
        } catch (e) {
          print('Could not get position: $e');
        }
      }
      
      try {
        currentVolume = await _vlcPlayerController!.getVolume();
        print('Current volume: $currentVolume');
      } catch (e) {
        print('Could not get volume: $e');
        currentVolume = 100;
      }
      
      // Save current audio track info
      try {
        final currentAudioId = await _vlcPlayerController!.getAudioTrack();
        final audioTracks = await _vlcPlayerController!.getAudioTracks();
        final selectedAudio = audioTracks.entries.firstWhere(
          (entry) => entry.key == currentAudioId,
          orElse: () => const MapEntry(-1, ''),
        );
        if (selectedAudio.key != -1) {
          currentAudioName = selectedAudio.value;
          // Try to get language from master playlist mapping if available
          if (_masterAudioTracks.isNotEmpty) {
            final masterTrack = _masterAudioTracks.firstWhere(
              (track) => track['name']?.toLowerCase() == selectedAudio.value.toLowerCase(),
              orElse: () => {},
            );
            currentAudioLanguage = masterTrack['language'];
          }
          print('Current audio saved: $currentAudioName (language: $currentAudioLanguage)');
        }
      } catch (e) {
        print('Could not save current audio: $e');
      }
      
      // Save current subtitle track info
      try {
        final currentSpuId = await _vlcPlayerController!.getSpuTrack();
        if (currentSpuId! >= 0) {
          final spuTracks = await _vlcPlayerController!.getSpuTracks();
          final selectedSpu = spuTracks.entries.firstWhere(
            (entry) => entry.key == currentSpuId,
            orElse: () => const MapEntry(-1, ''),
          );
          if (selectedSpu.key != -1) {
            currentSubName = selectedSpu.value;
            // Try to get language from master playlist mapping if available
            if (_masterSubtitleTracks.isNotEmpty) {
              final masterTrack = _masterSubtitleTracks.firstWhere(
                (track) => track['name']?.toLowerCase() == selectedSpu.value.toLowerCase(),
                orElse: () => {},
              );
              currentSubLanguage = masterTrack['language'];
            }
            print('Current subtitle saved: $currentSubName (language: $currentSubLanguage)');
          }
        } else {
          subtitlesDisabled = true;
          print('Subtitles are disabled');
        }
      } catch (e) {
        print('Could not save current subtitle: $e');
      }
      
      // 2) Determine preferred resolution for --preferred-resolution
      int? preferredHeight;
      if (index > 0 && _hlsVariants.isNotEmpty) {
        final variantIndex = index - 1; // Adjust for "Auto" option at index 0
        if (variantIndex < _hlsVariants.length) {
          final variant = _hlsVariants[variantIndex];
          // Extract height from resolution string (e.g., "1920x1080" -> 1080)
          if (variant.resolution != null) {
            final resolutionParts = variant.resolution!.split('x');
            if (resolutionParts.length == 2) {
              preferredHeight = int.tryParse(resolutionParts[1]);
            }
          }
          print('Setting preferred resolution: ${preferredHeight}p for ${variant.resolution}');
        }
      } else {
        print('Using auto/adaptive quality (no preferred resolution)');
      }
      
      // 3) Use the new reload function with preferred resolution
       final masterUrl = _masterPlaylistUrl ?? _videoUrl ?? '';
       await _reloadWithPreferredResolution(
         masterUrl: masterUrl,
         preferredHeight: preferredHeight,
         isLive: _isLiveStream,
         controller: _vlcPlayerController!,
         wasPlaying: wasPlaying ?? false,
         currentPos: currentPos,
         currentVolume: currentVolume,
       );
      
      // 4) Wait for tracks to be available
       await Future.delayed(const Duration(milliseconds: 250));
       
       // 5) Restore audio track by language/name matching
       if (currentAudioLanguage != null || currentAudioName != null) {
         try {
           final newAudioTracks = await _vlcPlayerController!.getAudioTracks();
           print('Available audio tracks after quality change: $newAudioTracks');
           MapEntry<int, String>? matchingAudio;
           
           // Try language match first if available
           if (currentAudioLanguage != null && _masterAudioTracks.isNotEmpty) {
             for (final entry in newAudioTracks.entries) {
               final masterTrack = _masterAudioTracks.firstWhere(
                 (track) => track['name']?.toLowerCase() == entry.value.toLowerCase(),
                 orElse: () => {},
               );
               if (masterTrack['language'] == currentAudioLanguage) {
                 matchingAudio = entry;
                 break;
               }
             }
           }
           
           // If no language match, try exact name match
           if (matchingAudio == null && currentAudioName != null) {
             for (final entry in newAudioTracks.entries) {
               if (entry.value.toLowerCase() == currentAudioName.toLowerCase()) {
                 matchingAudio = entry;
                 break;
               }
             }
           }
           
           // If no exact match, try partial name match
           if (matchingAudio == null && currentAudioName != null) {
             for (final entry in newAudioTracks.entries) {
               if (entry.value.toLowerCase().contains(currentAudioName.toLowerCase()) ||
                   currentAudioName.toLowerCase().contains(entry.value.toLowerCase())) {
                 matchingAudio = entry;
                 break;
               }
             }
           }
           
           if (matchingAudio != null) {
             await Future.delayed(const Duration(milliseconds: 200));
             await _vlcPlayerController!.setAudioTrack(matchingAudio.key);
             print('Audio track restored: ${matchingAudio.value}');
           } else {
             print('Could not restore audio track. Available: $newAudioTracks, Looking for: $currentAudioName (lang: $currentAudioLanguage)');
           }
         } catch (e) {
           print('Error restoring audio track: $e');
         }
       }
       
       // 6) Restore subtitle track by language/name matching
       if (!subtitlesDisabled && (currentSubLanguage != null || currentSubName != null)) {
         try {
           final newSpuTracks = await _vlcPlayerController!.getSpuTracks();
           print('Available subtitle tracks after quality change: $newSpuTracks');
           MapEntry<int, String>? matchingSpu;
           
           // Try language match first if available
           if (currentSubLanguage != null && _masterSubtitleTracks.isNotEmpty) {
             for (final entry in newSpuTracks.entries) {
               final masterTrack = _masterSubtitleTracks.firstWhere(
                 (track) => track['name']?.toLowerCase() == entry.value.toLowerCase(),
                 orElse: () => {},
               );
               if (masterTrack['language'] == currentSubLanguage) {
                 matchingSpu = entry;
                 break;
               }
             }
           }
           
           // If no language match, try exact name match
           if (matchingSpu == null && currentSubName != null) {
             for (final entry in newSpuTracks.entries) {
               if (entry.value.toLowerCase() == currentSubName.toLowerCase()) {
                 matchingSpu = entry;
                 break;
               }
             }
           }
           
           // If no exact match, try partial name match
           if (matchingSpu == null && currentSubName != null) {
             for (final entry in newSpuTracks.entries) {
               if (entry.value.toLowerCase().contains(currentSubName.toLowerCase()) ||
                   currentSubName.toLowerCase().contains(entry.value.toLowerCase())) {
                 matchingSpu = entry;
                 break;
               }
             }
           }
           
           if (matchingSpu != null) {
             await Future.delayed(const Duration(milliseconds: 200));
             await _vlcPlayerController!.setSpuTrack(matchingSpu.key);
             print('Subtitle track restored: ${matchingSpu.value}');
           } else {
             print('Could not restore subtitle track. Available: $newSpuTracks, Looking for: $currentSubName (lang: $currentSubLanguage)');
           }
         } catch (e) {
           print('Error restoring subtitle track: $e');
         }
       } else if (subtitlesDisabled) {
         // Restore disabled subtitles
         try {
           await Future.delayed(const Duration(milliseconds: 200));
           await _vlcPlayerController!.setSpuTrack(-1);
           print('Subtitles disabled as before');
         } catch (e) {
           print('Error disabling subtitles: $e');
         }
       }
       
       // 7) Update current quality index and reload options
       _currentQualityIndex = index;
       
       // Reload HLS options to sync our internal state
       await Future.delayed(const Duration(milliseconds: 200));
       await _loadHLSOptions();
      
      print('Quality change completed successfully using preferred-resolution');
      
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      print('Error in preferred-resolution quality change: $e');
      
      // Recovery: reload original stream
      try {
        if (_videoUrl != null) {
          await _vlcPlayerController!.setMediaFromNetwork(_videoUrl!);
          await _vlcPlayerController!.play();
          print('Recovered by reloading original stream');
        }
      } catch (recoveryError) {
        print('Recovery failed: $recoveryError');
      }
    } finally {
      _isChangingQuality = false;
    }
  }

  // Legacy method for backward compatibility
  void changeSubtitle(String? subtitleCode) {
    _currentSubtitle = subtitleCode;
    print('Subtitle changed to: $subtitleCode');
    if (_onStateChanged != null) {
      _onStateChanged!();
    }
  }
  // Dispose controller
  void dispose() {
    _vlcPlayerController?.dispose();
  }
}