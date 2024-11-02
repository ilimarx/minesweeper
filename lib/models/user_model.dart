import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String avatarUrl;
  final int bestTime;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.avatarUrl,
    required this.bestTime,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bestTime: data['bestTime'] ?? 0,
    );
  }
}
