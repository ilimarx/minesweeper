// Author: Ilia Markelov (xmarke00)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signs in a user using email and password.
  /// Returns the [User] if the sign-in is successful, or null otherwise.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Log the error for debugging purposes
      print("Sign-in error: $e");
      return null;
    }
  }

  /// Creates a new account with email, password, and username.
  /// Saves the user information in Firestore under the 'users' collection.
  /// Returns the [User] if the registration is successful, or null otherwise.
  Future<User?> createAccountWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'avatar': '', // Default empty avatar
        'bestTime': null, // Best time is initially set to null
      });

      return userCredential.user;
    } catch (e) {
      // Log the error for debugging purposes
      print("Registration error: $e");
      return null;
    }
  }
}
