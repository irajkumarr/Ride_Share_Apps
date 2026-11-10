import 'package:flutter/material.dart';

/// Floating Orange ETA Callout displayed above the destination marker during Route Preview.
class DestinationEtaCallout extends StatelessWidget {
  final Offset? screenOffset;
  final int durationMins;

  const DestinationEtaCallout({
    super.key,
    required this.screenOffset,
    required this.durationMins,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    const calloutWidth = 140.0;
    const calloutHeight = 85.0;

    final double posX;
    final double posY;

    if (screenOffset != null) {
      posX = (screenOffset!.dx - (calloutWidth / 2)).clamp(
        16.0,
        screenSize.width - calloutWidth - 16.0,
      );
      posY = (screenOffset!.dy - calloutHeight - 14.0).clamp(
        topPadding + 65.0,
        screenSize.height - 420.0,
      );
    } else {
      posX = screenSize.width - calloutWidth - 20.0;
      posY = topPadding + 75.0;
    }

    final arrivalTime = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(minutes: durationMins)),
    ).format(context);

    return Positioned(
      left: posX,
      top: posY,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4824),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4824).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$durationMins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'MIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              'arrive at $arrivalTime',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top Center Pill Badge: 🟢 ON TRIP | BA 2 PA 4092
class OnTripHeaderBadge extends StatelessWidget {
  final String licensePlate;

  const OnTripHeaderBadge({super.key, required this.licensePlate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 80,
      right: 76,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF062828),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ON TRIP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '|',
              style: TextStyle(color: Color(0xFF334155), fontSize: 13),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                licensePlate.isNotEmpty ? licensePlate : 'BA  2  PA  4092',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top Center Pill Badge: 🟢 DRIVER ARRIVED | BA 2 PA 4092
class DriverArrivedHeaderBadge extends StatelessWidget {
  final String licensePlate;

  const DriverArrivedHeaderBadge({super.key, required this.licensePlate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 80,
      right: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'DRIVER ARRIVED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '|',
              style: TextStyle(color: Color(0xFF475569), fontSize: 13),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                licensePlate.isNotEmpty ? licensePlate : 'BA 2 PA 4092',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Destination ETA Box & Flag Pin dynamically anchored over destination location.
class DestinationFlagPin extends StatelessWidget {
  final Offset? screenOffset;
  final String destinationTitle;
  final int? etaMinutes;
  final double? distanceKm;

  const DestinationFlagPin({
    super.key,
    required this.screenOffset,
    required this.destinationTitle,
    this.etaMinutes,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    const boxWidth = 190.0;
    const boxHeight = 90.0;

    final double posX;
    final double posY;

    if (screenOffset != null) {
      posX = (screenOffset!.dx - (boxWidth / 2)).clamp(
        16.0,
        screenSize.width - boxWidth - 16.0,
      );
      posY = (screenOffset!.dy - boxHeight - 8.0).clamp(
        topPadding + 65.0,
        screenSize.height - 380.0,
      );
    } else {
      posX = screenSize.width - boxWidth - 20.0;
      posY = topPadding + 65.0;
    }

    final effectiveEta = etaMinutes ?? 6;
    final etaTime = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(minutes: effectiveEta)),
    ).format(context);

    return Positioned(
      left: posX,
      top: posY,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF9800),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      destinationTitle.isNotEmpty
                          ? destinationTitle
                          : 'Sirjana nagar',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'ETA $etaTime ($effectiveEta min)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Destination Black Flag Pin anchored directly underneath
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.flag_rounded,
                color: Color(0xFFFF9800),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Approaching Motorcycle Marker dynamically anchored at driver position.
class ApproachingMotorcycleMarker extends StatelessWidget {
  final Offset? screenOffset;

  const ApproachingMotorcycleMarker({super.key, required this.screenOffset});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    const markerSize = 44.0;

    final double posX;
    final double posY;

    if (screenOffset != null) {
      posX = (screenOffset!.dx - (markerSize / 2)).clamp(
        16.0,
        screenSize.width - markerSize - 16.0,
      );
      posY = (screenOffset!.dy - (markerSize / 2)).clamp(
        topPadding + 65.0,
        screenSize.height - 300.0,
      );
    } else {
      posX = screenSize.width - markerSize - 24.0;
      posY = topPadding + 85.0;
    }

    return Positioned(
      left: posX,
      top: posY,
      child: Container(
        width: markerSize,
        height: markerSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFF4824), width: 2.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/bike.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/icons/bike.png',
                package: 'shared_core',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.two_wheeler_rounded,
                  color: Color(0xFFFF4824),
                  size: 22,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Top Center Pill Badge: 🟢 RIDE COMPLETED • BA 2 PA 4092
class TripCompletedHeaderBadge extends StatelessWidget {
  final String licensePlate;

  const TripCompletedHeaderBadge({super.key, required this.licensePlate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 76,
      right: 76,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF062828),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'RIDE COMPLETED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '•',
              style: TextStyle(color: Color(0xFF334155), fontSize: 12),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                licensePlate.isNotEmpty ? licensePlate : 'BA 2 PA 4092',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
