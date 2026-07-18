import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyHiveApp());
}

class MyHiveApp extends StatelessWidget {
  const MyHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Hive',
      theme: ThemeData(
        useMaterial3: true,
        // Global background color set to match your soft, muted yellow
        scaffoldBackgroundColor: const Color(0xFFFDF3C7), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A340),
          brightness: Brightness.light,
        ),
        // Setting Outfit as the global font package
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}