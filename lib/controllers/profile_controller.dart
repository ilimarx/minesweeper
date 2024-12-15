// Author: Andrii Bondarenko (xbonda06)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;

  // Filters for retrieving and displaying user games.
  Map<String, dynamic> filters = {
    'startDate': null,
    'endDate': null,
    'difficulty': null,
    'result': null,
    'reverseOrder': false,
  };

  /// Loads the profile data for the current user.
  Future<UserModel?> loadProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }

    return userModel;
  }

  /// Retrieves the list of games played by the specified user.
  Future<List<Map<String, dynamic>>> loadUserGames(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('games')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// Groups games by their dates while assigning them indices for display.
  Map<String, List<Map<String, dynamic>>> groupUserGames(List<Map<String, dynamic>> games) {
    final Map<String, List<Map<String, dynamic>>> groupedGames = {};
    int currentIndex = filters['reverseOrder'] == true ? 1 : games.length;

    for (var game in games) {
      final timestamp = (game['timestamp'] as Timestamp).toDate();
      final dateKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

      game['index'] = currentIndex;
      currentIndex += filters['reverseOrder'] == true ? 1 : -1;
      groupedGames.putIfAbsent(dateKey, () => []).add(game);
    }

    return groupedGames;
  }

  /// Applies the current filters to the user's games and returns the filtered results.
  Future<Map<String, List<Map<String, dynamic>>>> loadFilteredGames(String userId) async {
    List<Map<String, dynamic>> games = await loadUserGames(userId);

    // Filter games by start date.
    if (filters['startDate'] != null) {
      games = games.where((game) {
        final timestamp = (game['timestamp'] as Timestamp).toDate();
        return timestamp.isAfter(filters['startDate']);
      }).toList();
    }

    // Filter games by end date (inclusive).
    if (filters['endDate'] != null) {
      games = games.where((game) {
        final timestamp = (game['timestamp'] as Timestamp).toDate();
        return timestamp.isBefore(filters['endDate'].add(const Duration(days: 1)));
      }).toList();
    }

    // Filter games by difficulty level.
    if (filters['difficulty'] != null && filters['difficulty'] != -1) {
      games = games.where((game) => game['mines'] == filters['difficulty']).toList();
    }

    // Filter games by result (win/lose).
    if (filters['result'] != null && filters['result'] != 'all') {
      games = games.where((game) => game['result'] == filters['result']).toList();
    }

    // Reverse the order of games if the reverseOrder filter is true.
    if (filters['reverseOrder'] == true) {
      games = games.reversed.toList();
    }

    return groupUserGames(games);
  }

  /// Gets the rank of the current user based on their best time.
  Future<int?> getUserRank() async {
    if (userModel == null) return null;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .orderBy('bestTime', descending: false)
        .get();

    List<UserModel> users = snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.bestTime != -1)
        .toList();

    for (int i = 0; i < users.length; i++) {
      if (users[i].uid == userModel!.uid) {
        return i + 1; // Rank starts from 1.
      }
    }
    return null;
  }

  /// Formats the given time in seconds into a human-readable string.
  /// For example, 75 seconds becomes "1m 15s".
  String formatTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return '${timeInSeconds}s';
    }
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
