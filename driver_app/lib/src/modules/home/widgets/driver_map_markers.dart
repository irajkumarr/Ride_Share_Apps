import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Helper class to create realistic, premium driver location puck markers for Google Map
class DriverMapMarkers {
  DriverMapMarkers._();

  static BitmapDescriptor? _cachedDriverPuck;

  /// Generates a high-resolution teal concentric puck with directional arrow
  /// Scaled to 60.0 for an optimal balance of visibility and map real estate.
  static Future<BitmapDescriptor> getDriverPuckIcon() async {
    if (_cachedDriverPuck != null) return _cachedDriverPuck!;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // TARGET SIZE: 60.0
    const size = 60.0;
    const center = Offset(30.0, 30.0);

    // Outer subtle glow / shadow (radius: 26, blur: 4.5)
    final outerShadowPaint = Paint()
      ..color = const Color(0xFF00796B).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawCircle(center, 26, outerShadowPaint);

    // Dark teal primary circle (radius: 24)
    final outerRingPaint = Paint()
      ..color = const Color(0xFF00695C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 24, outerRingPaint);

    // Mid deep-slate ring (radius: 16.5)
    final innerPuckPaint = Paint()
      ..color = const Color(0xFF10282C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 16.5, innerPuckPaint);

    // Inner bright teal outline ring (radius: 16.5, stroke: 1.5)
    final innerRingOutline = Paint()
      ..color = const Color(0xFF00B4A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 16.5, innerRingOutline);

    // Directional Arrow Navigation icon in center (scaled proportionally)
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(30.0, 22.5); // Top tip
    arrowPath.lineTo(36.0, 36.0); // Bottom right
    arrowPath.lineTo(30.0, 33.0); // Notch center
    arrowPath.lineTo(24.0, 36.0); // Bottom left
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    _cachedDriverPuck = BitmapDescriptor.bytes(bytes);
    return _cachedDriverPuck!;
  }
}
