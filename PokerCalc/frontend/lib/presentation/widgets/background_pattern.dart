import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundPattern extends StatelessWidget {
  const BackgroundPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA), // Slightly off-white for better contrast
      child: CustomPaint(
        painter: _HoneycombPatternPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _HoneycombPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFE9ECEF) // Less transparent, light gray honeycomb
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double radius = 24.0;
    final double width = math.sqrt(3) * radius;
    final double height = 2 * radius;

    // Draw slightly beyond screen bounds
    for (double y = -height; y < size.height + height; y += height * 0.75) {
      final bool isOffsetRow = (y / (height * 0.75)).round() % 2 != 0;
      final double xOffset = isOffsetRow ? width / 2 : 0;

      for (double x = -width; x < size.width + width; x += width) {
        _drawHexagon(canvas, Offset(x + xOffset, y), radius, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle =
          (math.pi / 3) * i + math.pi / 6; // +pi/6 for flat top
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
