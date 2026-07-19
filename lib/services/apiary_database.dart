import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Cloud persistence for unlockable content (bee species, flower types,
/// and gamification state).
///
/// This replaces the local sqflite implementation to sync progress 
/// seamlessly across devices using Firebase Cloud Firestore.
class ApiaryDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to securely target the currently logged-in user's specific document
  DocumentReference get _userDoc {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Authentication Error: User must be logged in to access the Apiary.");
    }
    // Structures the database as: users -> [uid] -> game_data -> apiary
    return _db.collection('users').doc(user.uid).collection('game_data').doc('apiary');
  }

  Future<String?> getString(String key) async {
    try {
      final snapshot = await _userDoc.get();
      
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data[key] as String?;
      }
      return null; // Key doesn't exist yet
    } catch (e) {
      print('Firestore Read Error: $e');
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      // Using merge: true acts exactly like a local Key-Value store. 
      // It updates the specific key without overwriting the rest of the document.
      await _userDoc.set({
        key: value,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore Write Error: $e');
    }
  }
}