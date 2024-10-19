import 'package:flutter/material.dart';
import 'package:minesweeper/models/homepage_model.dart';

class HomepageController {
  final HomepageModel model;

 HomepageController(this.model);

  void selectDifficulty(String difficulty) {
    model.setDifficulty(difficulty);
  }

  String getSelectedDifficulty() {
    return model.selectedDifficulty;
  }

  void startGame(BuildContext context) {
    // Logic to navigate to the game view, passing in the selected difficulty
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MinesweeperView(
    //       controller: MinesweeperController(
    //         MinesweeperModel(rows: _getRowsBasedOnDifficulty(), columns: _getColsBasedOnDifficulty())
    //       ),
    //     ),
    //   ),
    // );
  }

  int _getRowsBasedOnDifficulty() {
    switch (model.selectedDifficulty) {
      case 'Easy':
        return 8;
      case 'Hard':
        return 16;
      default:
        return 10;
    }
  }

  int _getColsBasedOnDifficulty() {
    return _getRowsBasedOnDifficulty(); // Assuming square board
  }
}