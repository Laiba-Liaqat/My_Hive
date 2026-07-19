import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Paints a cluster of 7 interlocking hexagonal cells that fill with honey
/// as [progress] (0.0 - 1.0) increases. Features 3D-depth cell cups, a wavy
/// liquid honey surface with floating bubbles, and clean wax cell borders.
class HoneycombPainter extends CustomPainter {
  HoneycombPainter({
    required this.progress,
    required this.colonyHealth,
    this.animationTick = 0,
  });

  final double progress;
  final double colonyHealth;
  final double animationTick;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    final outerPath = _hexPath(center, radius);

    // Geometry of the 7 honeycomb cells (1 center, 6 surrounding)
    final double cellRadius = radius / 2.732;
    final double dist = cellRadius * math.sqrt(3);

    final List<Offset> cellCenters = [center];
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      cellCenters.add(center + Offset(dist * math.cos(angle), dist * math.sin(angle)));
    }

    // 1. Draw 3D deep cell cup backgrounds for each cell
    for (final cellCenter in cellCenters) {
      final cellBgPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1B0F05), // Dark deep cup interior
            HiveColors.combCream.withOpacity(0.55), // Creamy wax wall bottom
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: cellCenter, radius: cellRadius));

      final cellPath = _hexPath(cellCenter, cellRadius);
      canvas.drawPath(cellPath, cellBgPaint);
    }

    // 2. Liquid Honey Fill (clipping to the outer hex frame)
    canvas.save();
    canvas.clipPath(outerPath);

    if (progress > 0.02) {
      final fillTop = size.height * (1 - progress);
      final honeyRect = Rect.fromLTWH(0, fillTop, size.width, size.height);

      final healthTint = colonyHealth < 0.35
          ? HiveColors.wilted
          : HiveColors.honeyGold;

      final honeyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            healthTint.withOpacity(0.88),
            HiveColors.honeyDeep.withOpacity(0.95),
          ],
        ).createShader(honeyRect);

      // Wavy top surface for liquid texture.
      final wavePath = Path()..moveTo(0, fillTop);
      const waveWidth = 40.0;
      for (double x = 0; x <= size.width + waveWidth; x += waveWidth) {
        final waveOffset = math.sin((x / waveWidth) + animationTick) * 5;
        wavePath.quadraticBezierTo(
          x + waveWidth / 2,
          fillTop + waveOffset,
          x + waveWidth,
          fillTop,
        );
      }
      wavePath.lineTo(size.width, size.height);
      wavePath.lineTo(0, size.height);
      wavePath.close();

      canvas.drawPath(wavePath, honeyPaint);

      // Floating bubbles in the liquid honey
      final bubblePaint = Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.fill;
      final bubbleBorderPaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final bubbles = [
        Offset(size.width * 0.32, size.height * 0.68),
        Offset(size.width * 0.68, size.height * 0.74),
        Offset(size.width * 0.5, size.height * 0.58),
        Offset(size.width * 0.44, size.height * 0.8),
        Offset(size.width * 0.58, size.height * 0.48),
        Offset(size.width * 0.25, size.height * 0.52),
        Offset(size.width * 0.72, size.height * 0.60),
      ];

      for (int i = 0; i < bubbles.length; i++) {
        final bY = bubbles[i].dy + math.sin(animationTick + i) * 6;
        final bX = bubbles[i].dx + math.cos(animationTick * 0.5 + i) * 4;
        if (bY > fillTop + 15 && bY < size.height - 15) {
          final r = 2.5 + (i % 3);
          canvas.drawCircle(Offset(bX, bY), r, bubblePaint);
          canvas.drawCircle(Offset(bX, bY), r, bubbleBorderPaint);
        }
      }

      // Glossy highlight lines
      final glossPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(size.width * 0.28, fillTop + 10),
        Offset(size.width * 0.28, size.height - 10),
        glossPaint,
      );

      final topGlossPaint = Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.15, fillTop + 12)
          ..quadraticBezierTo(size.width * 0.5, fillTop + 5, size.width * 0.85, fillTop + 12),
        topGlossPaint,
      );
    }

    canvas.restore();

    // 3. Draw wax cell borders on top of the honey
    final cellBorderPaint = Paint()
      ..color = HiveColors.waxBrown.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;

    final cellInnerWallPaint = Paint()
      ..color = HiveColors.combCream.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    for (final cellCenter in cellCenters) {
      final cellPath = _hexPath(cellCenter, cellRadius);
      canvas.drawPath(cellPath, cellBorderPaint);
      canvas.drawPath(cellPath, cellInnerWallPaint);
    }

    // 4. Capped honey shimmer once nearly full
    if (progress > 0.92) {
      final capPaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (final cellCenter in cellCenters) {
        canvas.drawPath(_hexPath(cellCenter, cellRadius - 4), capPaint);
      }
    }

    // 5. Outer wooden/wax frame border
    final framePaint = Paint()
      ..color = HiveColors.waxBrown.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(outerPath, framePaint);

    final frameInnerPaint = Paint()
      ..color = HiveColors.combCream.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(_hexPath(center, radius - 3), frameInnerPaint);
  }

  Path _hexPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant HoneycombPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colonyHealth != colonyHealth ||
        oldDelegate.animationTick != animationTick;
  }
}
