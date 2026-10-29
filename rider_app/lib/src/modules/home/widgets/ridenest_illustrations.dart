import 'package:flutter/material.dart';

/// Custom painters and stylized widgets replicating the RideNest UI icons & cards
class BikeIllustration extends StatelessWidget {
  final double size;
  const BikeIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size * 0.62), painter: _BikePainter());
  }
}

class _BikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wheel details
    final wheelRadius = h * 0.28;
    final rearCenter = Offset(w * 0.22, h * 0.68);
    final frontCenter = Offset(w * 0.78, h * 0.68);

    // Tyre paint (Dark Charcoal)
    final tyrePaint = Paint()
      ..color = const Color(0xFF1E242B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wheelRadius * 0.46;

    // Rim paint (White / Silver)
    final rimPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    // Hub center paint
    final hubPaint = Paint()
      ..color = const Color(0xFF1E242B)
      ..style = PaintingStyle.fill;

    // Draw rear wheel
    canvas.drawCircle(rearCenter, wheelRadius * 0.77, tyrePaint);
    canvas.drawCircle(rearCenter, wheelRadius * 0.54, rimPaint);
    canvas.drawCircle(rearCenter, wheelRadius * 0.2, hubPaint);

    // Draw front wheel
    canvas.drawCircle(frontCenter, wheelRadius * 0.77, tyrePaint);
    canvas.drawCircle(frontCenter, wheelRadius * 0.54, rimPaint);
    canvas.drawCircle(frontCenter, wheelRadius * 0.2, hubPaint);

    // Bike Frame & Body (Vibrant Red)
    final redBodyPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.44, h * 0.38)
      ..cubicTo(w * 0.50, h * 0.32, w * 0.62, h * 0.32, w * 0.70, h * 0.40)
      ..lineTo(w * 0.74, h * 0.44)
      ..lineTo(w * 0.56, h * 0.58)
      ..lineTo(w * 0.36, h * 0.58)
      ..close();
    canvas.drawPath(bodyPath, redBodyPaint);

    // Fuel Tank / Seat Top Cushion (Dark Charcoal)
    final seatPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final seatPath = Path()
      ..moveTo(w * 0.32, h * 0.48)
      ..lineTo(w * 0.48, h * 0.42)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.33, h * 0.52)
      ..close();
    canvas.drawPath(seatPath, seatPaint);

    // Yellow headlight accent
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.70, h * 0.33), 3.5, yellowPaint);

    // Fork & Handlebar (Dark)
    final forkPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(frontCenter, Offset(w * 0.68, h * 0.26), forkPaint);
    // Handlebar grip
    canvas.drawLine(
      Offset(w * 0.65, h * 0.25),
      Offset(w * 0.72, h * 0.27),
      forkPaint,
    );

    // Swingarm to rear wheel
    final swingPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(w * 0.45, h * 0.58), rearCenter, swingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Car with sleek geometric profile, tinted window, and red/black diagonal racing stripes
class CarIllustration extends StatelessWidget {
  final double size;
  const CarIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size * 0.55), painter: _CarPainter());
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.05, h * 0.78, w * 0.90, h * 0.16),
      shadowPaint,
    );

    // Wheel positions
    final wheelRadius = h * 0.32;
    final wheelCenter = Offset(w * 0.74, h * 0.72);

    // White aerodynamic car body
    final carWhitePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(w * 0.12, h * 0.70)
      ..lineTo(w * 0.17, h * 0.70)
      ..lineTo(w * 0.28, h * 0.42)
      ..cubicTo(w * 0.33, h * 0.38, w * 0.72, h * 0.38, w * 0.76, h * 0.42)
      ..lineTo(w * 0.95, h * 0.70)
      ..lineTo(w * 0.88, h * 0.70)
      ..arcToPoint(
        Offset(w * 0.60, h * 0.70),
        radius: Radius.circular(wheelRadius * 1.15),
        clockwise: false,
      )
      ..lineTo(w * 0.12, h * 0.70)
      ..close();
    canvas.drawPath(bodyPath, carWhitePaint);

    // Red Front Light / Accent
    final redLight = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.68, 5, 7),
        const Radius.circular(2),
      ),
      redLight,
    );

    // Tinted Window (Dark blue-grey trapezoid)
    final windowPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final windowPath = Path()
      ..moveTo(w * 0.32, h * 0.66)
      ..lineTo(w * 0.37, h * 0.44)
      ..lineTo(w * 0.58, h * 0.44)
      ..lineTo(w * 0.58, h * 0.66)
      ..close();
    canvas.drawPath(windowPath, windowPaint);

    // Red & Dark Diagonal Stripes at rear
    final stripeRed = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final stripeDark = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final redStripePath = Path()
      ..moveTo(w * 0.67, h * 0.44)
      ..lineTo(w * 0.74, h * 0.44)
      ..lineTo(w * 0.83, h * 0.66)
      ..lineTo(w * 0.76, h * 0.66)
      ..close();
    canvas.drawPath(redStripePath, stripeRed);

    final darkStripePath = Path()
      ..moveTo(w * 0.76, h * 0.44)
      ..lineTo(w * 0.82, h * 0.44)
      ..lineTo(w * 0.94, h * 0.66)
      ..lineTo(w * 0.87, h * 0.66)
      ..close();
    canvas.drawPath(darkStripePath, stripeDark);

    // Wheel (Front / Prominent wheel)
    final tyrePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wheelRadius * 0.45;

    final rimPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final hubPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(wheelCenter, wheelRadius * 0.72, tyrePaint);
    canvas.drawCircle(wheelCenter, wheelRadius * 0.50, rimPaint);
    canvas.drawCircle(wheelCenter, wheelRadius * 0.18, hubPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cargo illustration displaying van outline + red cargo indicator badge
class CargoIllustration extends StatelessWidget {
  final double size;
  const CargoIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.58,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Cargo Van outline
          Positioned(
            left: 2,
            bottom: 2,
            child: Icon(
              Icons.airport_shuttle_rounded,
              size: size * 0.55,
              color: const Color(0xFFB45309), // Warm cargo brown
            ),
          ),
          // Red up-arrows packaging indicator badge
          Positioned(
            right: 18,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
          // Small round parcel/tag indicator
          Positioned(
            right: 2,
            bottom: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Delivery illustration displaying paper bag parcel + red packaged container
class DeliveryIllustration extends StatelessWidget {
  final double size;
  const DeliveryIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Kraft paper parcel bag
          Container(
            width: size * 0.34,
            height: size * 0.46,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB45309),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Red box with arrows label
          Container(
            width: size * 0.44,
            height: size * 0.46,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing concentric radar rings overlay with scanner rays for ride searching
class RadarOverlayWidget extends StatelessWidget {
  final Animation<double> animation;
  final Offset? centerOffset;
  const RadarOverlayWidget({
    super.key,
    required this.animation,
    this.centerOffset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _RadarPainter(
            progress: animation.value,
            centerOffset: centerOffset,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Offset? centerOffset;
  _RadarPainter({required this.progress, this.centerOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final center = centerOffset ?? Offset(size.width * 0.5, size.height * 0.38);
    final maxRadius = size.width * 0.85;

    // Subtle web / geometric polygon guidelines
    final rayPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw 3 subtle angular rays like in the reference map
    canvas.drawLine(
      center,
      Offset(size.width * 0.1, size.height * 0.1),
      rayPaint,
    );
    canvas.drawLine(
      center,
      Offset(size.width * 0.9, size.height * 0.15),
      rayPaint,
    );
    canvas.drawLine(
      center,
      Offset(size.width * 0.3, size.height * 0.65),
      rayPaint,
    );
    canvas.drawLine(
      center,
      Offset(size.width * 0.8, size.height * 0.7),
      rayPaint,
    );

    // Draw 3 expanding concentric radar rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.33)) % 1.0;
      final radius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.35;

      final ringPaint = Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      canvas.drawCircle(center, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Modern illustration loader that displays the PNG asset icon (with ground shadow and tier badges)
/// with graceful fallback to custom-painted vector representations.
class VehicleTierIllustration extends StatelessWidget {
  final String tierId;
  final double size;
  final bool isSelected;

  const VehicleTierIllustration({
    super.key,
    required this.tierId,
    this.size = 76,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    String? assetName;
    Widget fallback;
    Widget? badgeOverlay;

    switch (tierId.toLowerCase()) {
      case 'bike':
        assetName = 'bike.png';
        fallback = BikeIllustration(size: size);
        break;

      case 'fastest':
        // Fastest ride option: energetic lightning indicator
        assetName = 'car.png';
        fallback = CarIllustration(size: size);
        badgeOverlay = Positioned(
          right: 2,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(3.5),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66F59E0B),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
        );
        break;

      case 'comfort':
        // Premium executive sedan with gold luxury badge
        assetName = 'car.png';
        fallback = CarIllustration(size: size);
        badgeOverlay = Positioned(
          right: 2,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 10, color: Color(0xFFF59E0B)),
                SizedBox(width: 2),
                Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF8FAFC),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case 'xl':
        assetName = 'car.png';
        fallback = CarIllustration(size: size);
        badgeOverlay = Positioned(
          right: 2,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x442563EB),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '6 SEATS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
        break;

      case 'delivery':
      case 'parcel':
        assetName = null;
        fallback = DeliveryIllustration(size: size);
        break;

      case 'cargo':
      case 'van':
        assetName = null;
        fallback = CargoIllustration(size: size);
        break;

      case 'economy':
      default:
        assetName = 'car.png';
        fallback = CarIllustration(size: size);
        break;
    }

    final double width = size;
    final double height = size * 0.60;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft Ground Contact Shadow
          Positioned(
            bottom: 2,
            child: Container(
              width: width * 0.74,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF0F172A).withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: isSelected ? 8 : 4,
                    spreadRadius: isSelected ? 1 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Main vehicle image / vector
          AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: assetName != null
                ? Image.asset(
                    'assets/icons/$assetName',
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Secondary check: load from shared_core package
                      return Image.asset(
                        'assets/icons/$assetName',
                        package: 'shared_core',
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => fallback,
                      );
                    },
                  )
                : fallback,
          ),

          // Optional Badge Overlay
          ?badgeOverlay,
        ],
      ),
    );
  }
}
