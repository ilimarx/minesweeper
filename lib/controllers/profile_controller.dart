import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileController {
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

  Future<Map<String, List<Map<String, dynamic>>>> groupUserGamesWithIndices(String userId) async {
    final games = await loadUserGames(userId);

    final Map<String, List<Map<String, dynamic>>> groupedGames = {};
    int currentIndex = games.length;

    for (var game in games) {
      final timestamp = (game['timestamp'] as Timestamp).toDate();
      final dateKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

      game['index'] = currentIndex--;
      groupedGames.putIfAbsent(dateKey, () => []).add(game);
    }

    return groupedGames;
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

  String formatTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return '${timeInSeconds}s';
    }
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
