import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bee_animation.dart';
import 'glass_container.dart';
import 'honeycomb_painter.dart';

/// The centerpiece of the timer screen: a big glassy honeycomb that fills
/// with liquid honey as focus progresses, with bees orbiting in front of
/// and behind it to "collect" honey while active.
class HiveProgressWidget extends StatefulWidget {
  const HiveProgressWidget({
    super.key,
    required this.progress,
    required this.colonyHealth,
    required this.isActive,
    required this.centerLabel,
    required this.subLabel,
    this.beeEmoji = '🐝',
    this.flowerEmoji = '🍀',
    this.reduceMotion = false,
  });

  final double progress;
  final double colonyHealth;
  final bool isActive;
  final String centerLabel;
  final String subLabel;
  final String beeEmoji;
  final String flowerEmoji;
  final bool reduceMotion;

  @override
  State<HiveProgressWidget> createState() => _HiveProgressWidgetState();
}

class _HiveProgressWidgetState extends State<HiveProgressWidget>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _beeController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _beeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isActive) {
      _beeController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HiveProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_beeController.isAnimating) {
      _beeController.repeat();
    } else if (!widget.isActive && _beeController.isAnimating) {
      _beeController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _beeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 280.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size + 60,
      height: size + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow behind everything for a "liquid gold" feel.
          Container(
            width: size + 40,
            height: size + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HiveColors.honeyGold.withOpacity(widget.isActive ? 0.28 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Back layer of bees (behind the hive)
          HoneyCollectingBees(
            size: size + 40,
            active: widget.isActive,
            beeEmoji: widget.beeEmoji,
            reduceMotion: widget.reduceMotion,
            layer: BeeLayer.back,
            animation: _beeController,
          ),
          ClipOval(
            child: GlassContainer(
              borderRadius: size / 2,
              blur: 10,
              opacity: 0.25,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: size,
                height: size,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) => CustomPaint(
                    size: const Size(size, size),
                    painter: HoneycombPainter(
                      progress: widget.progress,
                      colonyHealth: widget.colonyHealth,
                      animationTick: widget.reduceMotion ? 0 : _waveController.value * 6.28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Front layer of bees (in front of the hive)
          HoneyCollectingBees(
            size: size + 40,
            active: widget.isActive,
            beeEmoji: widget.beeEmoji,
            reduceMotion: widget.reduceMotion,
            layer: BeeLayer.front,
            animation: _beeController,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.centerLabel,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      color: isDark ? HiveColors.combCream : HiveColors.waxBrown,
                      shadows: [
                        Shadow(
                          color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subLabel,
                style: TextStyle(
                  color: isDark ? HiveColors.combCream.withOpacity(0.75) : HiveColors.waxBrown.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: FocusFlower(
              emoji: widget.flowerEmoji,
              active: widget.isActive,
              reduceMotion: widget.reduceMotion,
            ),
          ),
        ],
      ),
    );
  }
}
