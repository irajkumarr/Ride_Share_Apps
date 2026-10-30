import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper to render custom styled map markers for Incoming Ride Requests
/// matching the exact design:
/// - Green walking person circle icon for pickup point
/// - Black badge with "PICKUP • 2 min" pill
/// - Black pill with "You (400m away)" label under driver
class RideRequestMapMarkers {
  RideRequestMapMarkers._();

  static BitmapDescriptor? _cachedPickupIcon;

  /// Marker for pickup location: Green circle with walking person icon and black ETA badge above
  static Future<BitmapDescriptor> getPickupMarkerIcon({
    String etaText = 'PICKUP • 2 min',
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const width = 240.0;
    const height = 130.0;

    // 1. Draw top black pill badge: [ • PICKUP • 2 min ]
    final badgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 10, 200, 42),
      const Radius.circular(21),
    );
    final badgePaint = Paint()
      ..color = const Color(0xFF0F1E21)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(badgeRect.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawRRect(badgeRect, badgePaint);

    // Green dot inside badge
    final dotPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(45, 31), 5.5, dotPaint);

    // Text "PICKUP • 2 min"
    final textPainter = TextPainter(
      text: TextSpan(
        text: etaText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(60, 21));

    // Small notch under pill badge pointing to circle below
    final notchPath = Path()
      ..moveTo(width / 2 - 8, 52)
      ..lineTo(width / 2 + 8, 52)
      ..lineTo(width / 2, 60)
      ..close();
    canvas.drawPath(notchPath, badgePaint);

    // 2. Green circular walking icon marker below badge
    const circleCenter = Offset(width / 2, 94);
    final circleOuterGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(circleCenter, 28, circleOuterGlow);

    final circlePaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, 24, circlePaint);

    final circleBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(circleCenter, 24, circleBorder);

    // Walking person icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_walk_rounded.codePoint),
        style: TextStyle(
          fontSize: 26,
          fontFamily: Icons.directions_walk_rounded.fontFamily,
          package: Icons.directions_walk_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - (iconPainter.width / 2),
        circleCenter.dy - (iconPainter.height / 2),
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Label marker under driver: "You (400m away)"
  static Future<BitmapDescriptor> getDriverDistanceLabelIcon({
    String text = 'You (400m away)',
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const width = 200.0;
    const height = 48.0;

    final pillRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 6, 180, 36),
      const Radius.circular(18),
    );
    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(pillRect.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(pillRect, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: 180);
    textPainter.paint(
      canvas,
      Offset(
        width / 2 - (textPainter.width / 2),
        height / 2 - (textPainter.height / 2),
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Marker for Accepted Ride Pickup:
  /// - Black pill badge with [📍 PICKUP]
  /// - Red glowing circular badge with person icon below
  static Future<BitmapDescriptor> getAcceptedPickupMarkerIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const width = 200.0;
    const height = 140.0;

    // 1. Black pill badge: [ 📍 PICKUP ]
    final badgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 10, 140, 38),
      const Radius.circular(19),
    );
    final badgePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(badgeRect.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawRRect(badgeRect, badgePaint);

    // Pin icon and text inside badge
    final badgeTextPainter = TextPainter(
      text: const TextSpan(
        text: '📍 PICKUP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    badgeTextPainter.layout();
    badgeTextPainter.paint(
      canvas,
      Offset(width / 2 - (badgeTextPainter.width / 2), 20),
    );

    // Notch pointing downward
    final notchPath = Path()
      ..moveTo(width / 2 - 7, 48)
      ..lineTo(width / 2 + 7, 48)
      ..lineTo(width / 2, 56)
      ..close();
    canvas.drawPath(notchPath, badgePaint);

    // 2. Red circular person icon marker
    const circleCenter = Offset(width / 2, 92);
    final circleOuterGlow = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(circleCenter, 28, circleOuterGlow);

    final circlePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, 22, circlePaint);

    final circleBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(circleCenter, 22, circleBorder);

    // Person icon in white
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.person_rounded.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: Icons.person_rounded.fontFamily,
          package: Icons.person_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - (iconPainter.width / 2),
        circleCenter.dy - (iconPainter.height / 2),
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Completed Trip Pickup Point: Small ring circle with black pill label [Gatthaghar]
  static Future<BitmapDescriptor> getCompletedPickupDotMarkerIcon({
    String label = 'Gatthaghar',
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const width = 160.0;
    const height = 48.0;

    // Outer double ring circle
    final ringCenter = const Offset(20, 24);
    final outerRing = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final innerDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ringCenter, 10, outerRing);
    canvas.drawCircle(ringCenter, 6, innerDot);

    // Dark slate label pill: [Gatthaghar]
    final labelRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(36, 6, 118, 36),
      const Radius.circular(10),
    );
    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(labelRect.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(labelRect, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 105);
    textPainter.paint(canvas, Offset(44, 24 - (textPainter.height / 2)));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Completed Trip Destination Point: Green checkered flag circle with dark pill label [Sundhara] below
  static Future<BitmapDescriptor> getCompletedDestinationFlagMarkerIcon({
    String label = 'Sundhara',
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const width = 140.0;
    const height = 90.0;

    // Green circular flag icon badge
    final flagCenter = const Offset(70, 26);
    final flagBgPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF059669).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(flagCenter, 22, glowPaint);
    canvas.drawCircle(flagCenter, 20, flagBgPaint);

    final whiteBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(flagCenter, 20, whiteBorder);

    // Flag icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.sports_score_rounded.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: Icons.sports_score_rounded.fontFamily,
          package: Icons.sports_score_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        flagCenter.dx - (iconPainter.width / 2),
        flagCenter.dy - (iconPainter.height / 2),
      ),
    );

    // Dark destination pill label below flag: [Sundhara]
    final labelRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 52, 110, 32),
      const Radius.circular(16),
    );
    final labelBgPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(labelRect.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(labelRect, labelBgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(70 - (textPainter.width / 2), 68 - (textPainter.height / 2)),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }
}
