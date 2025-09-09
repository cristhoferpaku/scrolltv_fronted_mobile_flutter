import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// HLS Quality Variant class
// HlsVariant class removed - quality functionality eliminated

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
  final List<Map<String, String>> _subtitleTracks = [];
  final List<Map<String, String>> _audioTracks = [];
  int _currentSubtitleIndex = -1;
  int _currentAudioIndex = 0;

  // Getters
  VlcPlayerController? get controller => _vlcPlayerController;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get hasEnded => _hasEnded;
  String? get currentSubtitle => _currentSubtitle;
  List<Map<String, String>> get subtitleTracks => _subtitleTracks;
  List<Map<String, String>> get audioTracks => _audioTracks;
  int get currentSubtitleIndex => _currentSubtitleIndex;
  int get currentAudioIndex => _currentAudioIndex;

  // Initialize player with URL
  void initializePlayer(String videoUrl, {VoidCallback? onStateChanged}) {
    _onStateChanged = onStateChanged;
    _videoUrl = videoUrl;
    // Master playlist functionality removed

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
      if (_totalDuration.inMilliseconds > 0 && _currentPosition.inMilliseconds >= _totalDuration.inMilliseconds - 1000) {
        if (!_hasEnded) {
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
        await _restartVideo();
        _hasEnded = false;
      } else if (_isPlaying) {
        _vlcPlayerController!.pause();
      } else {
        _vlcPlayerController!.play();
        // Reset ended state when playing normally
        if (_currentPosition.inMilliseconds < _totalDuration.inMilliseconds - 1000) {
          if (_hasEnded) {
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
        // Error restarting video
      }
    }
  }

  // Load HLS stream options
  Future<void> _loadHLSOptions() async {
    if (_vlcPlayerController == null) return;

    try {
      // Wait longer for player to be ready, especially for MP4 files
      await Future.delayed(const Duration(milliseconds: 3000));

      // Try multiple times if tracks are not available yet
      await _loadTracksWithRetry();
    } catch (e) {
      // Error loading video options
    }
  }

  // Load tracks with retry mechanism for MP4 files
  Future<void> _loadTracksWithRetry() async {
    int maxRetries = 5;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        // Clear existing options
        _subtitleTracks.clear();
        _audioTracks.clear();

        bool foundTracks = await _loadVideoTracks();

        if (foundTracks) {
          break;
        } else if (currentRetry < maxRetries - 1) {
          // No tracks found, wait and retry
          await Future.delayed(const Duration(milliseconds: 2000));
          currentRetry++;
        } else {
          _addDefaultTracks();
        }
      } catch (e) {
        if (currentRetry < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 2000));
          currentRetry++;
        } else {
          _addDefaultTracks();
        }
      }
    }

    // Sync current audio index and notify state change
    await _syncCurrentAudioIndex();
    if (_onStateChanged != null) {
      _onStateChanged!();
    }
  }

  // Load video tracks from VLC
  Future<bool> _loadVideoTracks() async {
    bool foundSubtitles = false;
    bool foundAudio = false;

    // Try to get real subtitle tracks from VLC
    try {
      final spuCount = await _vlcPlayerController!.getSpuTracks();
      // Add "Desactivados" option first
      _subtitleTracks.add({'id': '-1', 'name': 'Desactivados', 'language': 'none'});
      if (spuCount.isNotEmpty) {
        final sortedTracks = spuCount.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
        // Add real subtitle tracks from video stream in alphabetical order
        for (final entry in sortedTracks) {
          _subtitleTracks.add({'id': entry.key.toString(), 'name': entry.value, 'language': 'unknown'});
        }
        foundSubtitles = true;
      } else {}
    } catch (e) {
      _subtitleTracks.add({'id': '-1', 'name': 'Desactivados', 'language': 'none'});
    }

    // Try to get real audio tracks from VLC
    try {
      final audio = await _vlcPlayerController!.getAudioTracks();
      if (audio.isNotEmpty) {
        final sortedAudioTracks = audio.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
        for (final entry in sortedAudioTracks) {
          _audioTracks.add({'id': entry.key.toString(), 'name': entry.value, 'language': 'unknown'});
        }
        foundAudio = true;
      } else {
        print('No se encontraron pistas de audio específicas');
      }
      print('==========================');
    } catch (e) {
      print('Error loading audio tracks: $e');
    }

    return foundSubtitles || foundAudio;
  }

  // Add default tracks when no tracks are found
  void _addDefaultTracks() {
    // Add default subtitle option
    if (_subtitleTracks.isEmpty) {
      _subtitleTracks.add({'id': '-1', 'name': 'Desactivados', 'language': 'none'});
    }

    // Add default audio option
    if (_audioTracks.isEmpty) {
      _audioTracks.add({'id': '0', 'name': 'Audio Principal', 'language': 'unknown'});
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
        // Store the desired track name before rebuilding the list
        final desiredTrackName = _subtitleTracks[index]['name'];
        // Get current subtitle tracks from VLC to get the real IDs
        final currentTracks = await _vlcPlayerController!.getSpuTracks();

        if (currentTracks.isNotEmpty) {
          // Find the track ID that matches the desired track name
          int? targetTrackId;
          for (final entry in currentTracks.entries) {
            if (entry.value == desiredTrackName) {
              targetTrackId = entry.key;
              break;
            }
          }

          if (targetTrackId != null) {
            await _vlcPlayerController!.setSpuTrack(targetTrackId);
            _currentSubtitle = desiredTrackName;

            // Update our stored tracks with the current VLC track IDs
            // Convert to list and sort alphabetically by name
            final sortedCurrentTracks = currentTracks.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

            // Sync our stored tracks with current VLC tracks in alphabetical order
            _subtitleTracks.clear();
            _subtitleTracks.add({'id': '-1', 'name': 'Desactivados', 'language': 'none'});
            for (final entry in sortedCurrentTracks) {
              _subtitleTracks.add({'id': entry.key.toString(), 'name': entry.value, 'language': 'unknown'});
            }
          }
        } else {
          // Enable subtitle track with stored ID
          final trackId = int.tryParse(_subtitleTracks[index]['id'] ?? '0') ?? 0;
          await _vlcPlayerController!.setSpuTrack(trackId);
          _currentSubtitle = _subtitleTracks[index]['name'];
        }
      }

      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      // Error changing subtitle
    }
  }

  // Change audio track
  // Sync current audio index with VLC's actual playing track
  Future<void> _syncCurrentAudioIndex() async {
    if (_vlcPlayerController == null || _audioTracks.isEmpty) return;

    try {
      final currentTrackId = await _vlcPlayerController!.getAudioTrack();

      // Find the index that matches the current track ID
      for (int i = 0; i < _audioTracks.length; i++) {
        final trackId = int.tryParse(_audioTracks[i]['id'] ?? '0') ?? 0;
        if (trackId == currentTrackId) {
          _currentAudioIndex = i;
          break;
        }
      }
    } catch (e) {
      // Error syncing current audio index
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
        return;
      }

      // Set the audio track using the found ID
      await _vlcPlayerController!.setAudioTrack(targetTrackId);

      // Update our stored tracks with the current VLC track IDs
      // Convert to list and sort alphabetically by name
      final sortedCurrentTracks = currentTracks.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

      // Sync our stored tracks with current VLC tracks in alphabetical order
      _audioTracks.clear();
      for (final entry in sortedCurrentTracks) {
        _audioTracks.add({'id': entry.key.toString(), 'name': entry.value, 'language': 'unknown'});
      }

      // Sync the current index with what's actually playing
      await _syncCurrentAudioIndex();

      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    } catch (e) {
      // Error changing audio
    }
  }

  // Dispose controller
  void dispose() {
    _vlcPlayerController?.dispose();
  }
}
