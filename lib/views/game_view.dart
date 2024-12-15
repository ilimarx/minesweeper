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
  late GameController _gameController;
  late Timer _timer;
  int _elapsedTime = 0;
  bool isFlagMode = false;

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
              return Center(child: Text('Time: $_elapsedTime s'));
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFlagMode ? AppColors.primary : AppColors.surface,
              ),
              onPressed: () {
                setState(() {
                  isFlagMode = !isFlagMode;
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
                ],
              ),
            ),
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
              gameController.revealAllTiles();
              
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.rows, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.cols, (col) {
                      TileModel tile = gameController.grid[row][col];
                      bool isProcessing = false;

                      return GestureDetector(
                        onTap: () {
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
                              ? (tile.hasMine ? (gameController.gameWon ? AppColors.success : AppColors.error) : AppColors.surface)
                              : AppColors.primary,
                          child: Center(
                            child: tile.visible
                                ? (tile.hasMine
                                    ? SvgPicture.asset(
                                        'assets/images/mine.svg', // Replace with your mine SVG asset path
                                        width: 24,
                                        height: 24,
                                      )
                                    : (tile.value > 0
                                        ? Text(
                                            tile.value.toString(),
                                            style: const TextStyle(color: AppColors.textPrimary),
                                          )
                                        : const SizedBox()))
                                : (tile.hasFlag
                                    ? SvgPicture.asset(
                                        'assets/images/flag.svg', // Replace with your flag SVG asset path
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
    );
  }
}
