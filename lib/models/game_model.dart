import 'dart:math';
import 'tile_model.dart';

class GameModel {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<TileModel>> grid;

  GameModel({required this.rows, required this.cols, required this.mineCount}) {
    _initializeGrid();
    _placeMines();
    _calculateValues();
  }

  void _initializeGrid() {
    grid = List.generate(
        rows, (row) => List.generate(cols, (col) => TileModel(row, col)));
  }

  void _placeMines() {
    int placedMines = 0;
    Random random = Random();

    while (placedMines < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);

      if (!grid[row][col].hasMine) {
        grid[row][col].setMine = true;
        placedMines++;
      }
    }
  }

  bool isValidTile(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  void _calculateValues() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (!grid[row][col].hasMine) {
          int mineCount = _countAdjacentMines(row, col);
          grid[row][col].setValue = mineCount;
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        if (isValidTile(newRow, newCol) && grid[newRow][newCol].hasMine) {
          count++;
        }
      }
    }
    return count;
  }
}
