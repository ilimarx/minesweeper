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

  Future<UserModel?> loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }


  void selectDifficulty(String difficulty) {
    model.setDifficulty(difficulty);
  }

  String getSelectedDifficulty() {
    return model.selectedDifficulty;
  }

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

  int _getRowsBasedOnDifficulty() {
    switch (model.selectedDifficulty) {
      case 'Easy':
        return 8;
      case 'Hard':
        return 11;
      default:
        return 10;
    }
  }

  int _getColsBasedOnDifficulty() {
    return _getRowsBasedOnDifficulty(); // Assuming square board
  }

  int _getMinesBasedOnDifficulty() {
    switch (model.selectedDifficulty) {
      case 'Easy':
        return 5;
      case 'Hard':
        return 20;
      default:
        return 10;
    }
  }
}