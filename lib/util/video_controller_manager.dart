import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

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

  // Initialize player with URL
  void initializePlayer(String videoUrl, {VoidCallback? onStateChanged}) {
    _onStateChanged = onStateChanged;
    _videoUrl = videoUrl;
    
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
      
      // Try to get real quality levels from HLS
      print('=== ATTEMPTING TO GET REAL QUALITY LEVELS ===');
      _qualityLevels.clear();
      
      try {
        // Check if VLC has any video track information
        // Note: VLC may not expose HLS quality variants directly
        // but we can try to detect if adaptive streaming is available
        
        // Always add Auto option for HLS streams
        _qualityLevels.add({
          'id': '0', 
          'name': 'Auto (Adaptativo)', 
          'resolution': 'auto'
        });
        
        print('Added Auto quality option for HLS adaptive streaming');
        
        // For now, we don't add fixed quality options unless we can detect them
        // This prevents showing fake quality options that don't actually work
        print('Real quality variants detection not available in flutter_vlc_player');
        print('Using adaptive streaming only');
        
      } catch (e) {
        print('Error getting quality levels: $e');
        // Fallback to Auto only
        _qualityLevels = [
          {'id': '0', 'name': 'Auto', 'resolution': 'auto'},
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
    
    LoggerManager.log.i('=== CHANGING AUDIO TRACK ===');
    LoggerManager.log.i('Requested index: $index');
    LoggerManager.log.i('Current audio index: $_currentAudioIndex');
    LoggerManager.log.i('Available tracks: ${_audioTracks.length}');
    LoggerManager.log.i('Track to change to: ${_audioTracks[index]}');
    
    try {
      // Store the desired track name before rebuilding the list
      final desiredTrackName = _audioTracks[index]['name'];
      print('User wants to change to track: $desiredTrackName');
      
      // Get current audio tracks from VLC to get the real IDs
      final currentTracks = await _vlcPlayerController!.getAudioTracks();
      print('Current available tracks from VLC: $currentTracks');
      
      if (currentTracks.isEmpty) {
        print('No audio tracks available from VLC');
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
  
  // Change quality level (placeholder - VLC doesn't directly support this)
  void changeQualityLevel(int index) {
    if (index >= _qualityLevels.length) return;
    
    _currentQualityIndex = index;
    
    print('Quality changed to: ${_qualityLevels[index]['name']}');
    // Note: VLC player doesn't directly support quality switching for HLS
    // This would require re-initializing with a different stream URL
    
    if (_onStateChanged != null) {
      _onStateChanged!();
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