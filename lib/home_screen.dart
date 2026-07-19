import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Hive',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Home Screen (Focus Timer goes here!)',
          style: GoogleFonts.outfit(
            fontSize: 20,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}