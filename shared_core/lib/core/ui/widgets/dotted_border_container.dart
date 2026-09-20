import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;

  const DottedBorderContainer({
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.gap = 4.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderBoxPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DottedBorderBoxPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DottedBorderBoxPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = 0, y = 0;
    // Top border
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + gap, 0), paint);
      x += gap * 2;
    }
    // Bottom border
    x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + gap, size.height),
        paint,
      );
      x += gap * 2;
    }
    // Left border
    y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + gap), paint);
      y += gap * 2;
    }
    // Right border
    y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width, y + gap),
        paint,
      );
      y += gap * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
