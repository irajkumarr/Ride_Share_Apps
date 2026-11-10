import 'package:flutter/material.dart';

import '../../../../modules/home/widgets/ridenest_illustrations.dart';

export '../../../../modules/home/widgets/ridenest_illustrations.dart'
    show RadarOverlayWidget;

/// Animated radar rings centered on the pickup screen coordinate.
class DriverSearchingRadar extends StatelessWidget {
  final Animation<double> animation;
  final Offset? centerOffset;

  const DriverSearchingRadar({
    super.key,
    required this.animation,
    this.centerOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return RadarOverlayWidget(
              animation: animation,
              centerOffset: centerOffset,
            );
          },
        ),
      ),
    );
  }
}

/// Red Person Pin Callout anchored at the Pickup Location screen coordinate.
class PickupPersonPinCallout extends StatelessWidget {
  final Offset? screenOffset;

  const PickupPersonPinCallout({super.key, required this.screenOffset});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    const pinWidth = 56.0;
    const pinHeight = 74.0;

    final double posX;
    final double posY;

    if (screenOffset != null) {
      posX = (screenOffset!.dx - (pinWidth / 2)).clamp(
        16.0,
        screenSize.width - pinWidth - 16.0,
      );
      posY = (screenOffset!.dy - pinHeight).clamp(
        topPadding + 65.0,
        screenSize.height - 300.0,
      );
    } else {
      posX = (screenSize.width - pinWidth) / 2;
      posY = screenSize.height * 0.35;
    }

    return Positioned(
      left: posX,
      top: posY,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4824),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4824).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3.5),
            ),
          ),
        ],
      ),
    );
  }
}
