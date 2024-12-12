import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileController {
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
}
