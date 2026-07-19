import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A small flower that blooms beneath the hive while a session is active —
/// the destination bees swoop down to for their honey-collecting dips.
class FocusFlower extends StatelessWidget {
  const FocusFlower({super.key, required this.emoji, required this.active, this.reduceMotion = false});

  final String emoji;
  final bool active;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final content = Text(emoji, style: const TextStyle(fontSize: 26));
    if (reduceMotion) {
      return AnimatedOpacity(
        opacity: active ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: content,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: active ? 1.08 : 0.95),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: content,
    );
  }
}

enum BeeLayer { back, front, all }

/// Multiple bees orbit the hive and periodically swoop down to dip into a
/// flower beneath it, mimicking real honey-collecting flight — with a fast
/// wing-flutter layered on top. Degrades to a static, calm arrangement when
/// [reduceMotion] is set, per the app's accessibility settings.
class HoneyCollectingBees extends StatefulWidget {
  const HoneyCollectingBees({
    super.key,
    required this.size,
    required this.active,
    this.beeEmoji = '🐝',
    this.beeCount = 3,
    this.reduceMotion = false,
    this.layer = BeeLayer.all,
    this.animation,
  });

  final double size;
  final bool active;
  final String beeEmoji;
  final int beeCount;
  final bool reduceMotion;
  final BeeLayer layer;
  final Animation<double>? animation;

  @override
  State<HoneyCollectingBees> createState() => _HoneyCollectingBeesState();
}

class _HoneyCollectingBeesState extends State<HoneyCollectingBees>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;

  Animation<double> get _effectiveAnimation => widget.animation ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.animation == null) {
      _internalController = AnimationController(vsync: this, duration: const Duration(seconds: 8));
      if (widget.active) {
        _internalController!.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(covariant HoneyCollectingBees oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation == null && _internalController != null) {
      if (widget.active && !_internalController!.isAnimating) {
        _internalController!.repeat();
      } else if (!widget.active && _internalController!.isAnimating) {
        _internalController!.stop();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < widget.beeCount; i++) _buildStaticBee(i),
          ],
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _effectiveAnimation,
        builder: (context, _) {
          final t = _effectiveAnimation.value * 2 * math.pi;
          final flowerPos = Offset(0, widget.size / 2 - 4);

          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < widget.beeCount; i++) _buildBee(i, t, flowerPos),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaticBee(int i) {
    final angle = i * 2 * math.pi / widget.beeCount;
    final dy = (widget.size / 2 - 20) * 0.6 * math.sin(angle);
    final isFront = dy >= -5.0;

    if (widget.layer == BeeLayer.front && !isFront) {
      return const SizedBox.shrink();
    }
    if (widget.layer == BeeLayer.back && isFront) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: Offset(
        (widget.size / 2 - 20) * math.cos(angle),
        dy,
      ),
      child: Opacity(
        opacity: widget.active ? 0.9 : 0.35,
        child: Text(widget.beeEmoji, style: TextStyle(fontSize: widget.size * 0.075)),
      ),
    );
  }

  Widget _buildBee(int i, double t, Offset flowerPos) {
    final phase = i * (2 * math.pi / widget.beeCount);
    final speed = 1.0 + i * 0.15;
    final angle = t * speed + phase;

    final orbitRadius = widget.size / 2 - 18 - (i * 6);
    final orbitPos = Offset(
      orbitRadius * math.cos(angle),
      orbitRadius * 0.55 * math.sin(angle),
    );

    // Occasional sharp "dip" toward the flower to collect honey.
    final dipPulse = math.sin(t * 0.5 + phase);
    final dipFactor = widget.active ? math.pow(dipPulse.clamp(0, 1), 8).toDouble() : 0.0;

    final pos = Offset.lerp(orbitPos, flowerPos, dipFactor * 0.75)!;

    // Determine front vs back layer
    final isFront = pos.dy >= -5.0;

    if (widget.layer == BeeLayer.front && !isFront) {
      return const SizedBox.shrink();
    }
    if (widget.layer == BeeLayer.back && isFront) {
      return const SizedBox.shrink();
    }

    // Fast wing flutter, independent of the orbit speed.
    final flutter = math.sin(t * 30 + phase) * 0.12;
    final headingAngle = angle + math.pi / 2;

    return Transform.translate(
      offset: pos,
      child: Transform.rotate(
        angle: headingAngle,
        child: Transform.scale(
          scaleY: 1 + flutter,
          child: Opacity(
            opacity: widget.active ? 1.0 : 0.4,
            child: Text(widget.beeEmoji, style: TextStyle(fontSize: widget.size * 0.078)),
          ),
        ),
      ),
    );
  }
}
