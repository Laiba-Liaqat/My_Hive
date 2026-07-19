import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Accessibility + audio preferences, synced to the signed-in user's
/// Firestore document (`users/{uid}`, field `settings`) instead of
/// SharedPreferences, so they follow the user across devices.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  bool _reduceMotion = false;
  bool _soundEffects = true;
  bool _focusMusic = false;
  double _musicVolume = 0.85;
  double _textScale = 1.0;
  bool _smartNudges = true;
  bool _loaded = false;

  bool get reduceMotion => _reduceMotion;
  bool get soundEffects => _soundEffects;
  bool get focusMusic => _focusMusic;
  double get musicVolume => _musicVolume;
  double get textScale => _textScale;
  bool get smartNudges => _smartNudges;
  bool get loaded => _loaded;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<void> _load() async {
    final doc = _userDoc;
    if (doc != null) {
      try {
        final snapshot = await doc.get();
        final settings = snapshot.data()?['settings'] as Map<String, dynamic>?;
        if (settings != null) {
          _reduceMotion = settings['reduceMotion'] ?? false;
          _soundEffects = settings['soundEffects'] ?? true;
          _focusMusic = settings['focusMusic'] ?? false;
          _musicVolume = (settings['musicVolume'] ?? 0.85).toDouble();
          _textScale = (settings['textScale'] ?? 1.0).toDouble();
          _smartNudges = settings['smartNudges'] ?? true;
        }
      } catch (e) {
        // Sync hiccup (offline, not signed in yet, rules rejected it, etc).
        // Fall back to defaults rather than blocking startup/login.
        print('SettingsProvider load error: $e');
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Called after a successful login so a returning user's settings load
  /// from the cloud instead of staying at the pre-login defaults.
  Future<void> reload() async {
    _loaded = false;
    notifyListeners();
    await _load();
  }

  Future<void> _persist(String key, dynamic value) async {
    final doc = _userDoc;
    if (doc == null) return;
    try {
      await doc.set({
        'settings': {key: value},
      }, SetOptions(merge: true));
    } catch (e) {
      print('SettingsProvider save error: $e');
    }
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    await _persist('reduceMotion', value);
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffects = value;
    notifyListeners();
    await _persist('soundEffects', value);
  }

  Future<void> setFocusMusic(bool value) async {
    _focusMusic = value;
    notifyListeners();
    await _persist('focusMusic', value);
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value;
    notifyListeners();
    await _persist('musicVolume', value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    await _persist('textScale', value);
  }

  Future<void> setSmartNudges(bool value) async {
    _smartNudges = value;
    notifyListeners();
    await _persist('smartNudges', value);
  }

  /// Spring/elastic curves feel great but should collapse to a plain
  /// linear fade when the user asks for reduced motion.
  Curve get motionCurve => _reduceMotion ? Curves.linear : Curves.easeOutBack;

  Duration motionDuration(Duration full) =>
      _reduceMotion ? const Duration(milliseconds: 120) : full;
}
