import 'package:flutter/material.dart';
import 'package:shared_core/gen/assets.gen.dart';

import '../../config/global/app_global.dart';

class LoadingOverlay {
  static OverlayEntry? _currentOverlay;
  static bool _isVisible = false;

  /// Displays the loading overlay if not already visible.
  /// Automatically hides it after [autoHideInSec] seconds (default: 15 seconds).
  static void show({int autoHideInSec = 15}) {
    // Prevent multiple overlays being added
    if (_isVisible) return;

    _currentOverlay = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        child: Stack(
          children: [
            // Semi-transparent background to block user interaction
            const ModalBarrier(
              dismissible: false,
              barrierSemanticsDismissible: false,
              color: Colors.black26,
            ),
            // Centered loading indicator
            Center(
              child: Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade900.withValues(alpha: 0.1),
                      blurRadius: 5,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Colors.lightGreenAccent.shade700,
                  ),
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.indigo.shade50,
                ),
              ),
            ),

            // Image Icon:
            Center(
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(12),
                // child: Image.asset(
                //   Assets.icons.ridenestLogo.path,

                //   /// TODO: change image
                //   // colorFilter: const ColorFilter.mode(
                //   //   AppColor.black,
                //   //   BlendMode.srcIn,
                //   // ),
                // ),
                child: Assets.icons.ridenestLogo.image(
                  package: 'shared_core',
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_taxi_rounded,
                    color: Color(0xFF00B4A0),
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Safely insert the overlay if the navigator key is valid
    try {
      AppGlobal.navigatorKey.currentState?.overlay?.insert(_currentOverlay!);
      _isVisible = true;
    } catch (e) {
      debugPrint('Error showing LoadingOverlay: $e');
      _currentOverlay = null;
      _isVisible = false;
      return;
    }

    // Schedule automatic removal if autoHideInSec is greater than 0
    if (autoHideInSec > 0) {
      Future.delayed(Duration(seconds: autoHideInSec), () {
        if (_isVisible) {
          hide();
        }
      });
    }
  }

  /// Hides the loading overlay if it's currently visible.
  static void hide() {
    if (!_isVisible) {
      debugPrint('LoadingOverlay is not currently visible.');
      return;
    }

    try {
      _currentOverlay?.remove();
      _currentOverlay = null;
      _isVisible = false;
    } catch (e) {
      debugPrint('Error hiding LoadingOverlay: $e');
    }
  }
}
