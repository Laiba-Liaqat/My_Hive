import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bee_animation.dart';
import 'glass_container.dart';

/// A canvas-based "Meadow" environment that replaces a plain list with a
/// living scene: painted sky/grass, a hive box, bees in flight, and
/// blooming flowers that multiply as the apiary grows. This is the
/// Meadow's own bounded coordinate space — it doesn't reuse ScrollView
/// layout at all, so it stays a genuine `CustomPaint`/`Stack` composition
/// per the technical requirement.
class MeadowView extends StatelessWidget {
  const MeadowView({
    super.key,
    required this.jarCount,
    required this.colonyStrength, // 0..1, drives how "alive" the scene feels
    required this.beeEmoji,
    required this.flowerEmoji,
    this.reduceMotion = false,
    this.height = 320,
  });

  final int jarCount;
  final double colonyStrength;
  final String beeEmoji;
  final String flowerEmoji;
  final bool reduceMotion;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // More jars -> a fuller, busier meadow (endowed-progress payoff).
    final flowerCount = (2 + math.min(jarCount, 10)).clamp(2, 12).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _MeadowBackgroundPainter(isDark: isDark, colonyStrength: colonyStrength),
            ),
            // Flowers scattered along the grass baseline.
            for (int i = 0; i < flowerCount; i++)
              Positioned(
                left: _flowerX(i, flowerCount, height),
                bottom: _flowerY(i),
                child: _MeadowFlower(emoji: flowerEmoji, reduceMotion: reduceMotion, seed: i),
              ),
            // The hive box, centered.
            Align(
              alignment: const Alignment(0, 0.35),
              child: _HiveBox(strength: colonyStrength),
            ),
            // Bees orbiting/collecting around the hive.
            Align(
              alignment: const Alignment(0, 0.15),
              child: HoneyCollectingBees(
                size: math.min(height * 0.85, 260),
                active: colonyStrength > 0.05,
                beeEmoji: beeEmoji,
                beeCount: jarCount > 10 ? 4 : (jarCount > 3 ? 3 : 2),
                reduceMotion: reduceMotion,
              ),
            ),
            Positioned(
              left: 16,
              top: 14,
              child: GlassPill(
                child: Text(
                  '$jarCount jars in the meadow',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _flowerX(int i, int count, double h) {
    // Deterministic pseudo-random spread using the index as a seed so
    // layout doesn't jump between rebuilds.
    final t = (i * 0.61803398875) % 1.0; // golden-ratio scatter
    return 20 + t * 260 + (i.isEven ? 0 : 40);
  }

  double _flowerY(int i) => 8 + (i % 3) * 14;
}

class _MeadowFlower extends StatelessWidget {
  const _MeadowFlower({required this.emoji, required this.reduceMotion, required this.seed});
  final String emoji;
  final bool reduceMotion;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final text = Text(emoji, style: const TextStyle(fontSize: 20));
    if (reduceMotion) return text;
    final delayMs = (seed * 250) % 1400;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1600 + delayMs),
      curve: Curves.easeInOut,
      builder: (context, v, child) {
        final bob = math.sin(v * 2 * math.pi) * 3;
        return Transform.translate(offset: Offset(0, bob), child: child);
      },
      child: text,
    );
  }
}

class _HiveBox extends StatelessWidget {
  const _HiveBox({required this.strength});
  final double strength;

  @override
  Widget build(BuildContext context) {
    final glow = (0.15 + 0.35 * strength).clamp(0.0, 1.0);
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [HiveColors.honeyGold.withOpacity(glow), Colors.transparent],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HiveTier(width: 46, color: HiveColors.honeyAmber),
          _HiveTier(width: 58, color: HiveColors.honeyGold),
          _HiveTier(width: 68, color: HiveColors.honeyDeep),
        ],
      ),
    );
  }
}

class _HiveTier extends StatelessWidget {
  const _HiveTier({required this.width, required this.color});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: HiveColors.waxBrown.withOpacity(0.4)),
      ),
    );
  }
}

/// Paints the sky gradient, a soft sun/moon glow, and rolling grass hills.
class _MeadowBackgroundPainter extends CustomPainter {
  _MeadowBackgroundPainter({required this.isDark, required this.colonyStrength});

  final bool isDark;
  final double colonyStrength;

  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    final skyColors = isDark
        ? [const Color(0xFF241708), const Color(0xFF3A2712)]
        : [const Color(0xFFFFE9C7), const Color(0xFFFFF6E5)];
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyColors,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Sun glow
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          HiveColors.honeyGold.withOpacity(0.35 + 0.25 * colonyStrength),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.82, size.height * 0.18), radius: 90));
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.18), 90, sunPaint);

    // Rolling hills (two layers for depth)
    final backHill = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.62, size.width * 0.5, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.82, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      backHill,
      Paint()..color = (isDark ? const Color(0xFF2E4A22) : const Color(0xFFBFE0A0)).withOpacity(0.55),
    );

    final frontHill = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.75, size.width * 0.55, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.95, size.width, size.height * 0.82)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      frontHill,
      Paint()..color = isDark ? const Color(0xFF3A5A2A) : const Color(0xFF9FD17E),
    );
  }

  @override
  bool shouldRepaint(covariant _MeadowBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.colonyStrength != colonyStrength;
}
