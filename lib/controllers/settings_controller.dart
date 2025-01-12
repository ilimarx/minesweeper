// Author: Andrii Bondarenko (xbonda06)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Handles all user-related settings operations, including profile updates and sign-out.
class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;

  /// Loads the current user's profile from Firestore.
  Future<void> loadUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return; // Exit if no user is logged in.

    // Fetch the user's document from Firestore.
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isNotEmpty;
  }


  /// Updates the user's profile in Firestore with the given data.
  Future<void> updateUserProfile({
    required String uid,
    required String username,
    required String avatarUrl,
  }) async {
    // Update username and avatar URL in the user's Firestore document.
    await _firestore.collection('users').doc(uid).update({
      'username': username,
      'avatar': avatarUrl,
    });
  }

  /// Signs out the current user from the application.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
