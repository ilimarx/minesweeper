import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;

  Map<String, dynamic> filters = {
    'startDate': null,
    'endDate': null,
    'difficulty': null,
    'result': null,
    'reverseOrder': false,
  };

  Future<UserModel?> loadProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    }

    return userModel;
  }

  Future<List<Map<String, dynamic>>> loadUserGames(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('games')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

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

  Future<Map<String, List<Map<String, dynamic>>>> loadFilteredGames(String userId) async {
    List<Map<String, dynamic>> games = await loadUserGames(userId);

    if (filters['startDate'] != null) {
      games = games.where((game) {
        final timestamp = (game['timestamp'] as Timestamp).toDate();
        return timestamp.isAfter(filters['startDate']);
      }).toList();
    }

    if (filters['endDate'] != null) {
      games = games.where((game) {
        final timestamp = (game['timestamp'] as Timestamp).toDate();
        return timestamp.isBefore(filters['endDate'].add(const Duration(days: 1)));
      }).toList();
    }

    if (filters['difficulty'] != null && filters['difficulty'] != -1) {
      games = games.where((game) => game['mines'] == filters['difficulty']).toList();
    }

    if (filters['result'] != null && filters['result'] != 'all') {
      games = games.where((game) => game['result'] == filters['result']).toList();
    }

    if (filters['reverseOrder'] == true) {
      games = games.reversed.toList();
    }

    return groupUserGames(games);
  }

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
        return i + 1;
      }
    }
    return null;
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
