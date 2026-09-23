import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Notification Alert Service to handle ringing sound and repetitive vibration patterns
/// when a new ride dispatch request arrives for the driver.
class RideNotificationAlertService {
  RideNotificationAlertService._();
  static final RideNotificationAlertService instance = RideNotificationAlertService._();

  Timer? _alertTimer;
  bool _isPlaying = false;
  bool _isMuted = false;

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;

  /// Update mute state. If muted while playing, stops sound immediately.
  /// If unmuted while alert is active, resumes alert immediately.
  void setMuted(bool muted) {
    if (_isMuted == muted) return;
    _isMuted = muted;
    if (_isMuted) {
      // Silence immediately
      _stopAlert();
    } else {
      // If we were supposed to be active, trigger alert pulse
      if (_isPlaying) {
        _playAlertPulse();
      }
    }
  }

  /// Start repeating sound and vibration alert for incoming ride request.
  void startAlert({bool isMuted = false}) {
    _isMuted = isMuted;
    _isPlaying = true;

    _alertTimer?.cancel();

    if (!_isMuted) {
      _playAlertPulse();
    } else {
      // If muted, we can still do a gentle single haptic feedback if desired,
      // or remain completely silent according to user preference.
    }

    // Repeat every 1.5 seconds while incoming request is active
    _alertTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      if (!_isMuted) {
        _playAlertPulse();
      }
    });
  }

  /// Stop and reset sound & vibration
  void stopAlert() {
    _isPlaying = false;
    _stopAlert();
  }

  void _stopAlert() {
    _alertTimer?.cancel();
    _alertTimer = null;
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  void _playAlertPulse() async {
    try {
      // 1. Play system alert chime / notification sound
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();

      // 2. Custom vibration pattern (high-energy double buzz: 400ms on, 200ms off, 400ms on)
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        final hasPattern = await Vibration.hasCustomVibrationsSupport();
        if (hasPattern == true) {
          Vibration.vibrate(
            pattern: [0, 400, 200, 400],
            intensities: [0, 255, 0, 255],
          );
        } else {
          Vibration.vibrate(duration: 800);
        }
      }
    } catch (_) {
      // Fallback to basic haptics
      HapticFeedback.vibrate();
    }
  }
}
