import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/models/game_model.dart';
import 'package:minesweeper/models/tile_model.dart';

class GameController extends ChangeNotifier {
  late GameModel _gameModel;
  bool _gameOver = false;
  bool _gameWon = false;
  Stopwatch _stopwatch = Stopwatch();

  GameController(int rows, int cols, int mineCount) {
    _gameModel = GameModel(rows: rows, cols: cols, mineCount: mineCount);
    _stopwatch.start();
  }

  List<List<TileModel>> get grid => _gameModel.grid;
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;

  void revealTile(int row, int col) {
    if (_gameOver || _gameModel.grid[row][col].visible) return;

    _gameModel.grid[row][col].setVisible = true;
    if (_gameModel.grid[row][col].hasMine) {
      _stopwatch.stop();
      _gameOver = true;
      _saveGame(false);
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

  void revealAllTiles() {
    for (int i = 0; i < _gameModel.rows; i++) {
      for (int j = 0; j < _gameModel.cols; j++) {
        _gameModel.grid[i][j].setVisible = true;
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
    _stopwatch.stop();
    _gameWon = true;
    _gameOver = true;
    _saveGame(true);
  }

  Future<void> _saveGame(bool win) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final int timeTaken = _stopwatch.elapsed.inSeconds;
    final gameData = {
      'result': win ? 'win' : 'lose',
      'time': timeTaken,
      'timestamp': FieldValue.serverTimestamp(),
      'mines': _gameModel.mineCount,
    };

    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final gamesRef = userRef.collection('games');

    await gamesRef.add(gameData);

    if (win) {
      final userDoc = await userRef.get();
      final userBestTime = userDoc.data()?['bestTime'] ?? -1;

      if (userBestTime == -1 || timeTaken < userBestTime) {
        await userRef.update({'bestTime': timeTaken});
      }
    }
  }

  void resetGame(int rows, int cols, int mineCount) {
    _gameModel = GameModel(rows: rows, cols: cols, mineCount: mineCount);
    _gameOver = false;
    _gameWon = false;
    notifyListeners();
  }
}