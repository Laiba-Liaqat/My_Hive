import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/focus_session.dart';
import '../theme/app_theme.dart';

/// A stylized, depth-illusion "3D" apiary: rows of jars/combs are scaled
/// and shaded by row to fake perspective (closer rows = larger + brighter),
/// built purely with Transform + gradients so it stays lightweight and
/// works everywhere Flutter runs, no external 3D engine required.
class Apiary3DView extends StatelessWidget {
  const Apiary3DView({super.key, required this.jars});

  final List<HoneyJar> jars;

  static const _huePalette = [
    Color(0xFFF7C948), // morning blossom - light gold
    Color(0xFFF5A623), // afternoon clover - classic gold
    Color(0xFFD9822B), // evening buckwheat - amber
    Color(0xFF9C6B1F), // night lavender - dark honey
    Color(0xFFB86B00), // midnight wildflower - deep amber
  ];

  @override
  Widget build(BuildContext context) {
    if (jars.isEmpty) {
      return _EmptyApiary();
    }

    // Rows nearest the "camera" (bottom) hold fewer, larger jars.
    const perRow = [4, 6, 8, 10];
    final rows = <List<HoneyJar>>[];
    int index = 0;
    for (final count in perRow) {
      if (index >= jars.length) break;
      final end = math.min(index + count, jars.length);
      rows.add(jars.sublist(index, end));
      index = end;
    }
    // Any remainder goes in a final back row.
    if (index < jars.length) {
      rows.add(jars.sublist(index));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HiveColors.combCream.withOpacity(0.35),
            HiveColors.honeyGold.withOpacity(0.12),
          ],
        ),
      ),
      child: Column(
        children: [
          for (int r = rows.length - 1; r >= 0; r--) ...[
            _ApiaryRow(
              jars: rows[r],
              depthFactor: 1 - (r / (rows.length + 1)), // 0 = back, ~1 = front
              huePalette: _huePalette,
            ),
            const SizedBox(height: 10),
          ],
          // The wooden shelf floor.
          Container(
            height: 14,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: HiveColors.waxBrown.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiaryRow extends StatelessWidget {
  const _ApiaryRow({
    required this.jars,
    required this.depthFactor,
    required this.huePalette,
  });

  final List<HoneyJar> jars;
  final double depthFactor; // 0 (far/small) -> 1 (near/large)
  final List<Color> huePalette;

  @override
  Widget build(BuildContext context) {
    final scale = 0.55 + 0.45 * depthFactor;
    final opacity = 0.55 + 0.45 * depthFactor;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.bottomCenter,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: jars
              .map((jar) => _HoneyJarWidget(
                    jar: jar,
                    color: huePalette[jar.hue.clamp(0, huePalette.length - 1)],
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _HoneyJarWidget extends StatelessWidget {
  const _HoneyJarWidget({required this.jar, required this.color});

  final HoneyJar jar;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${jar.date.day}/${jar.date.month}/${jar.date.year} • ${jar.honeyMl.toStringAsFixed(0)}ml',
      child: Container(
        width: 40,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.85), color],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 16,
              height: 6,
              decoration: BoxDecoration(
                color: HiveColors.waxBrown,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('🍯', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyApiary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: HiveColors.combCream.withOpacity(0.3),
      ),
      child: Column(
        children: [
          const Text('🐝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Your apiary is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete a focus session to add your first jar of honey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: HiveColors.wilted),
          ),
        ],
      ),
    );
  }
}
