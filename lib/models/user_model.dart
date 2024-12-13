import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String avatar;
  final int bestTime;
  final int playedGames;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.avatar,
    required this.bestTime,
    required this.playedGames
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      avatar: data['avatar'] ?? '',
      bestTime: data['bestTime'] ?? -1,
      playedGames: data['playedGames'] ?? 0
    );
  }
}
