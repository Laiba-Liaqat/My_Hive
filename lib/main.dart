import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/customization_provider.dart';
import 'services/apiary_database.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';

import 'theme/app_theme.dart';

// I added the "providers/" path directly here
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storageService = StorageService();
  final audioService = AudioService();
  final notificationService = NotificationService();

runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CustomizationProvider()), 
        Provider<AudioService>(
          create: (_) => audioService,
          dispose: (_, service) => service.dispose(),
        ),
        Provider<NotificationService>(create: (_) => notificationService),
        
        // ADD THIS LINE
        ChangeNotifierProvider(create: (_) => FocusProvider(storageService)), 
      ],
      child: const MyHiveApp(),
    ),
  );
}

class MyHiveApp extends StatelessWidget {
  const MyHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'My Hive',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}