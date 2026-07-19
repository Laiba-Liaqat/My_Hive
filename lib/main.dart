import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // New import
import 'firebase_options.dart'; // New import
import 'splash_screen.dart';

// 1. Change main() to an asynchronous function
void main() async {
  // 2. Ensure Flutter's engine is fully running before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Boot up Firebase using the auto-generated settings
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        scaffoldBackgroundColor: const Color(0xFFFDF3C7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A340),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}