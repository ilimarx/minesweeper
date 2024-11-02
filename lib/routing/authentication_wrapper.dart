import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minesweeper/views/auth_view.dart';  // Your main game menu view
import 'package:minesweeper/views/homepage_view.dart';  // Authentication view for sign in
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/models/homepage_model.dart';

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homepageModel = HomepageModel();
    final homepageController = HomepageController(homepageModel);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // If the user is logged in, show the game menu
          User? user = snapshot.data;
          if (user == null) {
            return AuthView();  // Show sign-in page if not authenticated
          } else {
            return HomepageView(controller: homepageController);  // Show main game menu if authenticated
          }
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}