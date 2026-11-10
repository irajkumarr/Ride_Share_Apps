import 'package:flutter/material.dart';

/// Floating back button anchored above the bottom sheet.
class FloatingMapBackButton extends StatelessWidget {
  final double bottomOffset;
  final VoidCallback onPressed;

  const FloatingMapBackButton({
    super.key,
    required this.bottomOffset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomOffset,
      left: 20,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 24,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Floating GPS recenter button anchored above the bottom sheet.
class FloatingRecenterButton extends StatelessWidget {
  final double bottomOffset;
  final VoidCallback onPressed;

  const FloatingRecenterButton({
    super.key,
    required this.bottomOffset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomOffset,
      right: 20,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.my_location_rounded,
            color: Colors.black,
            size: 24,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Circular top-left back button used during driver-assigned and completed trips.
class TopCircularBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TopCircularBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 18,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
            size: 22,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Circular top-right close 'X' button used during trip-completed state.
class TopCircularCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TopCircularCloseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 18,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFF0F172A),
            size: 22,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
