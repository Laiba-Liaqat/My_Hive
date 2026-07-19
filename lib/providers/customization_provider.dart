import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bee_species.dart'; // Adjust if your models are in a different path

class CustomizationProvider extends ChangeNotifier {
  CustomizationProvider() {
    _load();
  }

  String _activeBeeId = BeeSpecies.all.first.id;
  String _activeFlowerId = FlowerType.all.first.id;
  int _completedSessions = 0;
  double _totalHoneyMl = 0;
  bool _loaded = false;

  String get activeBeeId => _activeBeeId;
  String get activeFlowerId => _activeFlowerId;
  bool get loaded => _loaded;
  double get totalHoneyMl => _totalHoneyMl;

  BeeSpecies get activeBee =>
      BeeSpecies.all.firstWhere((b) => b.id == _activeBeeId, orElse: () => BeeSpecies.all.first);
  FlowerType get activeFlower =>
      FlowerType.all.firstWhere((f) => f.id == _activeFlowerId, orElse: () => FlowerType.all.first);

  bool isBeeUnlocked(BeeSpecies b) => _completedSessions >= b.unlockSessionsRequired;
  bool isFlowerUnlocked(FlowerType f) => _totalHoneyMl >= f.unlockTotalHoneyMl;

  // Helper to dynamically get the logged-in user's database document
  DocumentReference? get _userDoc {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }

  Future<void> _load() async {
    final doc = _userDoc;
    if (doc != null) {
      try {
        final snapshot = await doc.get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _activeBeeId = data['activeBeeId'] ?? BeeSpecies.all.first.id;
          _activeFlowerId = data['activeFlowerId'] ?? FlowerType.all.first.id;
          _completedSessions = data['completedSessions'] ?? 0;
          _totalHoneyMl = (data['totalHoneyMl'] ?? 0).toDouble();
        }
      } catch (e) {
        // A permission-denied/offline/etc error here must NEVER propagate:
        // this used to throw straight out of reload(), which auth_screen.dart
        // awaits *before* navigating — so a Firestore hiccup silently killed
        // login entirely (auth succeeded, but the user never left the screen).
        print('CustomizationProvider load error: $e');
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Called by AuthScreen after a successful login to sync the new user's cloud data
  Future<void> reload() async {
    _loaded = false;
    notifyListeners();
    await _load();
  }

  /// Updates local state AND saves the new stats to the cloud.
  void refreshUnlocks({required int completedSessions, required double totalHoneyMl}) {
    _completedSessions = completedSessions;
    _totalHoneyMl = totalHoneyMl;
    notifyListeners();

    // SetOptions(merge: true) updates only these fields without wiping the rest of the document
    _userDoc?.set({
      'completedSessions': _completedSessions,
      'totalHoneyMl': _totalHoneyMl,
    }, SetOptions(merge: true));
  }

  List<BeeSpecies> newlyUnlockedBees(int previousCompleted) {
    return BeeSpecies.all
        .where((b) =>
            b.unlockSessionsRequired > previousCompleted &&
            b.unlockSessionsRequired <= _completedSessions)
        .toList();
  }

  List<FlowerType> newlyUnlockedFlowers(double previousHoneyMl) {
    return FlowerType.all
        .where((f) =>
            f.unlockTotalHoneyMl > previousHoneyMl && f.unlockTotalHoneyMl <= _totalHoneyMl)
        .toList();
  }

  Future<void> setActiveBee(BeeSpecies bee) async {
    if (!isBeeUnlocked(bee)) return;
    _activeBeeId = bee.id;
    notifyListeners();
    await _userDoc?.set({'activeBeeId': bee.id}, SetOptions(merge: true));
  }

  Future<void> setActiveFlower(FlowerType flower) async {
    if (!isFlowerUnlocked(flower)) return;
    _activeFlowerId = flower.id;
    notifyListeners();
    await _userDoc?.set({'activeFlowerId': flower.id}, SetOptions(merge: true));
  }
}