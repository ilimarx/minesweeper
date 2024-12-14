import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LeaderboardController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;


  Future<UserModel?> loadProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }

    return userModel;
  }

  Future<List<UserModel>> loadLeaderboard() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .orderBy('bestTime', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.bestTime != -1)
        .toList();
  }

  Future<int?> getUserRank(String uid) async {
    final leaderboard = await loadLeaderboard();
    final index = leaderboard.indexWhere((user) => user.uid == uid);
    return index != -1 ? index + 1 : null;
  }

  String formatTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return '${timeInSeconds}s';
    }
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

}
