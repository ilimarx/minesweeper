// Author: Ilia Markelov (xmarke00)

import 'dart:math';
import 'tile_model.dart';

/// The `GameModel` class manages the game grid and its operations,
/// including initializing the grid, placing mines, and calculating values.
class GameModel {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<TileModel>> grid;

  /// Constructor initializes the game grid and sets up mines and values.
  GameModel({required this.rows, required this.cols, required this.mineCount}) {
    _initializeGrid();
    _placeMines();
    _calculateValues();
  }

  /// Initializes the grid with `TileModel` objects for each cell.
  void _initializeGrid() {
    grid = List.generate(
        rows, (row) => List.generate(cols, (col) => TileModel(row, col)));
  }

  /// Randomly places the specified number of mines in the grid.
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

  /// Validates whether the given row and column are within the grid bounds.
  bool isValidTile(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  /// Calculates the number of mines adjacent to each tile.
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

  /// Counts the mines in the surrounding tiles of the given position.
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
