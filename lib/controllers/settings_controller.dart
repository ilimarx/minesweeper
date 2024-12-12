import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;

  Future<void> loadUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String username,
    required String avatarUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'username': username,
      'avatar': avatarUrl,
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
