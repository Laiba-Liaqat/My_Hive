import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A translucent, blurred "honey glass" surface — used throughout the app
/// so panels feel like they're cut from a honeycomb cell or a glass jar
/// rather than opaque cards sitting on top of the content.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 18,
    this.padding,
    this.opacity = 0.55,
    this.borderColor,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? HiveColors.darkCard : HiveColors.lightCard;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.6)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A softer glass pill, used for chips/toggles/badges.
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (color ?? (isDark ? HiveColors.darkCard : Colors.white)).withOpacity(0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(isDark ? 0.08 : 0.6)),
          ),
          child: child,
        ),
      ),
    );
  }
}
