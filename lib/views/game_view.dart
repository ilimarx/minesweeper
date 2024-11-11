import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minesweeper/controllers/game_controller.dart';
import 'package:minesweeper/models/tile_model.dart';

class GameView extends StatelessWidget {
  final int rows;
  final int cols;
  final int mineCount;

  GameView({required this.rows, required this.cols, required this.mineCount});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(rows, cols, mineCount),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Minesweeper')),
            actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                builder: (context) => GameView(rows: rows, cols: cols, mineCount: mineCount),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(rows, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cols, (col) {
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
                          margin: EdgeInsets.all(2),
                          color: tile.visible
                              ? (tile.hasMine ? Colors.red : Colors.grey)
                              : Colors.blue,
                          child: Center(
                            child: Text(
                              tile.visible
                                  ? (tile.hasMine ? 'M' : (tile.value > 0 ? tile.value.toString() : ''))
                                  : (tile.hasFlag ? 'F' : ''),
                              style: TextStyle(color: Colors.white),
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