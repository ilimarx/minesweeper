// Author: Andrii Bondarenko (xbonda06)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LeaderboardController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;

  /// Loads the current user's profile.
  /// Returns `null` if the user is not authenticated or their profile doesn't exist.
  Future<UserModel?> loadProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }

    return userModel;
  }

  /// Loads the leaderboard.
  /// If a difficulty is provided, filters users based on their best time in games with that difficulty.
  Future<List<UserModel>> loadLeaderboard({int? difficulty}) async {
    if (difficulty == null) {
      // Default leaderboard sorted by best time.
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('bestTime', descending: false)
          .get();

      // Exclude users with no valid best time (-1).
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.bestTime != -1)
          .toList();
    } else {
      // Leaderboard for a specific difficulty.
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      List<UserModel> filteredUsers = [];

      for (var doc in usersSnapshot.docs) {
        String userId = doc.id;

        // Fetch the user's best game for the specified difficulty.
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

          // Update the user model with the best time for the difficulty.
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

      // Sort the filtered users by best time.
      filteredUsers.sort((a, b) => a.bestTime.compareTo(b.bestTime));

      return filteredUsers;
    }
  }

  /// Gets the user's rank on the leaderboard.
  /// Returns `null` if the user is not found on the leaderboard.
  Future<int?> getUserRank(String uid, int? difficulty) async {
    final leaderboard = await loadLeaderboard(difficulty: difficulty);
    final index = leaderboard.indexWhere((user) => user.uid == uid);
    return index != -1 ? index + 1 : null;
  }

  /// Gets the user's best time for a specific difficulty.
  /// If no difficulty is provided, returns the general best time.
  Future<int?> getBestTimeForDifficulty(String uid, int? difficulty) async {
    if (difficulty == null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        var user = UserModel.fromFirestore(userDoc);
        return user.bestTime != -1 ? user.bestTime : null;
      }
      return null;
    } else {
      // Fetch the best game for the specified difficulty.
      QuerySnapshot gamesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .where('result', isEqualTo: 'win')
          .where('mines', isEqualTo: difficulty)
          .orderBy('time', descending: false)
          .limit(1)
          .get();

      if (gamesSnapshot.docs.isNotEmpty) {
        return gamesSnapshot.docs.first['time'];
      }
      return null;
    }
  }

  /// Gets the total number of games played by the user.
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

  /// Formats the time in seconds into a human-readable string (e.g., "1m 30s").
  String formatTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return '${timeInSeconds}s';
    }
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
