import 'dart:async';
import 'package:flutter/material.dart';

class VideoControlsManager {
  bool _showControls = true;
  Timer? _hideTimer;
  VoidCallback? _onControlsChanged;

  // Getter
  bool get showControls => _showControls;

  // Initialize with callback
  void initialize({VoidCallback? onControlsChanged}) {
    _onControlsChanged = onControlsChanged;
  }

  // Toggle controls visibility
  void toggleControls() {
    _showControls = !_showControls;
    _notifyChange();
    
    if (_showControls) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  // Show controls
  void show() {
    if (!_showControls) {
      _showControls = true;
      _notifyChange();
      _startHideTimer();
    }
  }

  // Hide controls
  void hideControls() {
    if (_showControls) {
      _showControls = false;
      _notifyChange();
    }
    _cancelHideTimer();
  }

  // Start auto-hide timer
  void _startHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(Duration(seconds: 10), () {
      hideControls();
    });
  }

  // Cancel auto-hide timer
  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  // Reset timer (when user interacts)
  void resetTimer() {
    if (_showControls) {
      _startHideTimer();
    }
  }

  // Notify state change
  void _notifyChange() {
    if (_onControlsChanged != null) {
      _onControlsChanged!();
    }
  }

  // Dispose
  void dispose() {
    _cancelHideTimer();
  }
}