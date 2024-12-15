// Author: Ilia Markelov (xmarke00)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minesweeper/controllers/game_controller.dart';
import 'package:minesweeper/models/tile_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minesweeper/theme/colors.dart';

class GameView extends StatefulWidget {
  final int rows;
  final int cols;
  final int mineCount;

  GameView({required this.rows, required this.cols, required this.mineCount});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late GameController _gameController; // Manages game logic
  late Timer _timer; // Tracks elapsed time
  int _elapsedTime = 0; // Stores time in seconds
  bool isFlagMode = false; // Toggles flag mode

  @override
  void initState() {
    super.initState();
    _gameController = GameController(widget.rows, widget.cols, widget.mineCount);
    _startTimer();
  }

  // Starts the timer to track game duration
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameController.gameOver) {
        timer.cancel(); // Stop the timer if the game ends
      } else {
        setState(() {
          _elapsedTime++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameController,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<GameController>(
            builder: (context, gameController, child) {
              // Display elapsed time in the app bar
              return Center(child: Text('Time: $_elapsedTime s'));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Restart the game
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameView(
                      rows: widget.rows,
                      cols: widget.cols,
                      mineCount: widget.mineCount,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Consumer<GameController>(
              builder: (context, gameController, child) {
                // Show game result (win/lose)
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    gameController.gameOver
                        ? (gameController.gameWon ? 'You Win!' : 'You Lose!')
                        : '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: gameController.gameWon ? AppColors.success : AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            Expanded(
              child: Consumer<GameController>(
                builder: (context, gameController, child) {
                  if (gameController.gameOver) {
                    gameController.revealAllTiles(); // Reveal all tiles when the game ends
                  }

                  // Render game grid
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.rows, (row) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.cols, (col) {
                            TileModel tile = gameController.grid[row][col];

                            return GestureDetector(
                              onTap: () {
                                // Toggle flag or reveal tile
                                if (isFlagMode) {
                                  _gameController.toggleFlag(row, col);
                                } else {
                                  _gameController.revealTile(row, col);
                                }
                              },
                              onLongPress: () {
                                _gameController.toggleFlag(row, col);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.all(2),
                                color: tile.visible
                                    ? (tile.hasMine
                                    ? (gameController.gameWon
                                    ? AppColors.success
                                    : AppColors.error)
                                    : AppColors.surface)
                                    : AppColors.primary,
                                child: Center(
                                  child: tile.visible
                                      ? (tile.hasMine
                                      ? SvgPicture.asset(
                                    'assets/images/mine.svg',
                                    width: 24,
                                    height: 24,
                                  )
                                      : (tile.value > 0
                                      ? Text(
                                    tile.value.toString(),
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                  )
                                      : const SizedBox()))
                                      : (tile.hasFlag
                                      ? SvgPicture.asset(
                                    'assets/images/flag.svg',
                                    width: 24,
                                    height: 24,
                                  )
                                      : const SizedBox()),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: AppColors.background,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFlagMode ? AppColors.primary : AppColors.surface,
                ),
                onPressed: () {
                  setState(() {
                    isFlagMode = !isFlagMode; // Toggle flag mode
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/flag.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFlagMode ? 'Flag Mode On' : 'Flag Mode Off',
                      style: TextStyle(
                        color: isFlagMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
