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

  Future<List<UserModel>> loadLeaderboard({int? difficulty}) async {
    if (difficulty == null) {
      // Default behavior: load leaderboard based on `bestTime`
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('bestTime', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.bestTime != -1)
          .toList();
    } else {
      // Filter users based on the best game time with specific difficulty
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      List<UserModel> filteredUsers = [];

      for (var doc in usersSnapshot.docs) {
        String userId = doc.id;
        QuerySnapshot gamesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('games')
            .where('result', isEqualTo: 'win')
            .where('mines', isEqualTo: difficulty)
            .orderBy('time', descending: false)
            .limit(1)
            .get();

        if (gamesSnapshot.docs.isNotEmpty) {
          var gameDoc = gamesSnapshot.docs.first;
          var originalUser = UserModel.fromFirestore(doc);

          // Create a new instance of UserModel with updated bestTime
          var updatedUser = UserModel(
            email: originalUser.email,
            uid: originalUser.uid,
            username: originalUser.username,
            avatar: originalUser.avatar,
            bestTime: gameDoc['time'],
            playedGames: originalUser.playedGames,
          );

          filteredUsers.add(updatedUser);
        }
      }

      // Sort users by best time for the filtered difficulty
      filteredUsers.sort((a, b) => a.bestTime.compareTo(b.bestTime));



      return filteredUsers;
    }
  }

  Future<int?> getUserRank(String uid, int? difficulty) async {
    final leaderboard = await loadLeaderboard(difficulty: difficulty);
    final index = leaderboard.indexWhere((user) => user.uid == uid);
    return index != -1 ? index + 1 : null;
  }

  Future<int> getPlayedGamesCount(String userId) async {
    try {
      final gamesCollection = await _firestore
          .collection('users')
          .doc(userId)
          .collection('games')
          .get();

      return gamesCollection.docs.length;
    } catch (e) {
      print("Error fetching played games count: $e");
      return 0;
    }
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
