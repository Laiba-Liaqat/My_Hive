import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/focus_session.dart';

/// Cloud persistence for sessions, theme choice, and lightweight settings.
///
/// Replaces the old SharedPreferences-backed version: everything now lives
/// in Firestore under the signed-in user's own document
/// (`users/{uid}`), so a person's history and preferences follow them
/// across devices instead of staying stuck on one phone.
///
/// Every read/write is wrapped in try/catch and simply no-ops (or returns
/// null/empty) on failure — e.g. while signed out, offline, or if Firestore
/// security rules reject the request. That's deliberate: a sync hiccup
/// here should never throw and block the UI (that's what previously broke
/// login — see auth_screen.dart).
class StorageService {
  static const _sessionsField = 'sessions';
  static const _themeField = 'themeMode';
  static const _lastDurationField = 'lastDuration';

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<Map<String, dynamic>?> _read() async {
    final doc = _userDoc;
    if (doc == null) return null;
    try {
      final snap = await doc.get();
      return snap.data();
    } catch (e) {
      print('StorageService read error: $e');
      return null;
    }
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final doc = _userDoc;
    if (doc == null) return;
    try {
      await doc.set(data, SetOptions(merge: true));
    } catch (e) {
      print('StorageService write error: $e');
    }
  }

  Future<List<FocusSession>> loadSessions() async {
    final data = await _read();
    final raw = data?[_sessionsField] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw
          .map((e) => FocusSession.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<FocusSession> sessions) async {
    await _write({_sessionsField: sessions.map((s) => s.toJson()).toList()});
  }

  Future<void> clearSessions() async {
    await _write({_sessionsField: []});
  }

  Future<String?> loadThemeMode() async {
    final data = await _read();
    return data?[_themeField] as String?;
  }

  Future<void> saveThemeMode(String mode) async {
    await _write({_themeField: mode});
  }

  Future<int?> loadLastDuration() async {
    final data = await _read();
    final v = data?[_lastDurationField];
    return v is int ? v : null;
  }

  Future<void> saveLastDuration(int minutes) async {
    await _write({_lastDurationField: minutes});
  }
}
