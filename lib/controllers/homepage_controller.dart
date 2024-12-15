/// Author: Ilia Markelov (xmarke00)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/models/homepage_model.dart';
import 'package:minesweeper/views/game_view.dart';

import '../models/user_model.dart';

class HomepageController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HomepageModel model;

  HomepageController(this.model);

  /// Loads the current user's data from Firestore.
  Future<UserModel?> loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  /// Updates the selected difficulty in the model.
  void selectDifficulty(String difficulty) {
    model.setDifficulty(difficulty);
  }

  /// Retrieves the selected difficulty from the model.
  String getSelectedDifficulty() {
    return model.selectedDifficulty;
  }

  /// Updates the selected theme in the model.
  void selectTheme(String theme) {
    model.setTheme(theme);
  }

  /// Retrieves the selected theme from the model.
  String getSelectedTheme() {
    return model.selectedTheme;
  }

  /// Starts a new game by navigating to the GameView with the selected settings.
  void startGame(BuildContext context) {
    int rows = _getRowsBasedOnDifficulty();
    int cols = _getColsBasedOnDifficulty();
    int mines = _getMinesBasedOnDifficulty();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameView(rows: rows, cols: cols, mineCount: mines),
      ),
    );
  }

  /// Determines the number of rows for the board based on the selected difficulty.
  int _getRowsBasedOnDifficulty() {
    switch (model.selectedDifficulty) {
      case 'Easy':
        return 8;
      case 'Hard':
        return 11;
      default:
        return 10; // Default case for 'Medium' or unhandled values
    }
  }

  /// Determines the number of columns for the board.
  /// Assumes the board is square, so it matches the row count.
  int _getColsBasedOnDifficulty() {
    return _getRowsBasedOnDifficulty();
  }

  /// Determines the number of mines based on the selected difficulty.
  int _getMinesBasedOnDifficulty() {
    switch (model.selectedDifficulty) {
      case 'Easy':
        return 5;
      case 'Hard':
        return 20;
      default:
        return 10; // Default case for 'Medium' or unhandled values
    }
  }
}
