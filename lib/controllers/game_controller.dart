import 'package:flutter/material.dart';
import 'package:minesweeper/models/game_model.dart';
import 'package:minesweeper/models/tile_model.dart';

class GameController extends ChangeNotifier {
  late GameModel _gameModel;
  bool _gameOver = false;
  bool _gameWon = false;

  GameController(int rows, int cols, int mineCount) {
    _gameModel = GameModel(rows: rows, cols: cols, mineCount: mineCount);
  }

  List<List<TileModel>> get grid => _gameModel.grid;
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;

  void revealTile(int row, int col) {
    if (_gameOver || _gameModel.grid[row][col].visible) return;

    _gameModel.grid[row][col].setVisible = true;
    if (_gameModel.grid[row][col].hasMine) {
      _gameOver = true;
      notifyListeners();
      return;
    }

    if (_gameModel.grid[row][col].value == 0) {
      _revealAdjacentTiles(row, col);
    }

    _checkWinCondition();
    notifyListeners();
  }

  void toggleFlag(int row, int col) {
    if (_gameOver || _gameModel.grid[row][col].visible) return;

    _gameModel.grid[row][col].setFlag = !_gameModel.grid[row][col].hasFlag;
    notifyListeners();
  }

  void _revealAdjacentTiles(int row, int col) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        if (_gameModel.isValidTile(newRow, newCol) && !_gameModel.grid[newRow][newCol].visible) {
          revealTile(newRow, newCol);
        }
      }
    }
  }

  void _checkWinCondition() {
    for (int row = 0; row < _gameModel.rows; row++) {
      for (int col = 0; col < _gameModel.cols; col++) {
        if (!_gameModel.grid[row][col].hasMine && !_gameModel.grid[row][col].visible) {
          return;
        }
      }
    }
    _gameWon = true;
    _gameOver = true;
  }

  void resetGame(int rows, int cols, int mineCount) {
    _gameModel = GameModel(rows: rows, cols: cols, mineCount: mineCount);
    _gameOver = false;
    _gameWon = false;
    notifyListeners();
  }
}