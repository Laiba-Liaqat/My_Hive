import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade in the text and icon
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Slightly scale up the text and icon
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Animate the background from dark charcoal to the muted yellow
    _colorAnimation = ColorTween(
      begin: const Color(0xFF121212), // Dark starting color
      end: const Color(0xFFFDF3C7),   // Bright, muted yellow ending color
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      // TODO: Replace with navigation to your actual Home Screen
      print("Splash screen finished. Moving to focus timer..."); 
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder listens to the color animation and rebuilds the Scaffold's background
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Clean structural hexagon icon
                    const Icon(
                      Icons.hexagon_outlined, 
                      size: 72,
                      color: Color(0xFFD4A340), 
                    ),
                    const SizedBox(height: 24),
                    // App Name with Outfit font
                    Text(
                      'My Hive',
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w400, 
                        letterSpacing: 2.0,
                        color: const Color(0xFF3A3A3A), 
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'DEEP FOCUS',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6.0,
                        color: const Color(0xFFB5A27A), 
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}