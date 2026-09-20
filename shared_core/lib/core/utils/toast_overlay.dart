import 'package:flutter/material.dart';
import '../../config/global/app_global.dart';

enum ToastType { success, warning, failure, normal }

class ToastOverlay {
  static OverlayEntry? _currentOverlay;
  static bool _isVisible = false;

  /// Displays the toast overlay if not already visible.
  /// Automatically hides it after [autoHideInSec] seconds (default: 3 seconds).
  static void show(String message, {ToastType type = ToastType.normal}) {
    // Prevent multiple overlays from being added
    if (_isVisible) return;

    // Determine the color, icon, and label based on the ToastType
    Color backgroundColor;
    IconData iconData;
    Color iconColor;
    var autoHideInSec = 3;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green.withValues(alpha: 0.8);
        iconData = Icons.check_circle;
        iconColor = Colors.white;
        autoHideInSec = 3;
      case ToastType.warning:
        backgroundColor = Colors.orange.withValues(alpha: 0.8);
        iconData = Icons.warning;
        iconColor = Colors.white;
        autoHideInSec = 5;
      case ToastType.failure:
        backgroundColor = Colors.red.withValues(alpha: 0.8);
        iconData = Icons.error;
        iconColor = Colors.white;
        autoHideInSec = 7;
      case ToastType.normal:
        backgroundColor = Colors.black.withValues(alpha: 0.7);
        iconData = Icons.info_outline;
        iconColor = Colors.white;
        autoHideInSec = 3;
    }

    _currentOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Positioned toast message at the bottom center
          Positioned(
            bottom: 100, // Set distance from the bottom
            left: 20, // Add padding to left
            right: 20, // Add padding to right
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: hide, // Dismiss on tap
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, color: iconColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            softWrap: true, // Allow text to wrap
                            overflow: TextOverflow.fade, // Ensure no truncation
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Safely insert the overlay if the navigator key is valid
    try {
      AppGlobal.navigatorKey.currentState?.overlay?.insert(_currentOverlay!);
      _isVisible = true;
    } catch (e) {
      debugPrint('Error showing ToastOverlay: $e');
      _currentOverlay = null;
      _isVisible = false;
      return;
    }

    // Schedule automatic removal after [autoHideInSec] seconds
    if (autoHideInSec > 0) {
      Future.delayed(Duration(seconds: autoHideInSec), () {
        if (_isVisible) {
          hide();
        }
      });
    }
  }

  /// Hides the toast overlay if it's currently visible.
  static void hide() {
    if (!_isVisible) {
      debugPrint('ToastOverlay is not currently visible.');
      return;
    }

    try {
      _currentOverlay?.remove();
      _currentOverlay = null;
      _isVisible = false;
    } catch (e) {
      debugPrint('Error hiding ToastOverlay: $e');
    }
  }
}
