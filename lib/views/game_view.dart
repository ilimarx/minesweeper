import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minesweeper/controllers/game_controller.dart';
import 'package:minesweeper/models/tile_model.dart';

class GameView extends StatefulWidget {
  final int rows;
  final int cols;
  final int mineCount;

  GameView({required this.rows, required this.cols, required this.mineCount});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late GameController _gameController;
  late Timer _timer;
  int _elapsedTime = 0;

  @override
  void initState() {
    super.initState();
    _gameController = GameController(widget.rows, widget.cols, widget.mineCount);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameController.gameOver) {
        timer.cancel();
      } else {
        setState(() {
          _elapsedTime++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
              if (gameController.gameOver) {
                return Text(gameController.gameWon ? 'You Won!' : 'Game Over');
              }
              return Text('Time: $_elapsedTime s');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
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
        body: Consumer<GameController>(
          builder: (context, gameController, child) {
            if (gameController.gameOver) {
              return Center(
                child: Text(
                  gameController.gameWon ? 'You Won!' : 'Game Over',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }

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
                          gameController.revealTile(row, col);
                        },
                        onLongPress: () {
                          gameController.toggleFlag(row, col);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.all(2),
                          color: tile.visible
                              ? (tile.hasMine ? Colors.red : Colors.grey)
                              : Colors.blue,
                          child: Center(
                            child: Text(
                              tile.visible
                                  ? (tile.hasMine ? 'M' : (tile.value > 0 ? tile.value.toString() : ''))
                                  : (tile.hasFlag ? 'F' : ''),
                              style: const TextStyle(color: Colors.white),
                            ),
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
    );
  }
}
