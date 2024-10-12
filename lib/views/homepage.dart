import 'package:flutter/material.dart';
import 'package:minesweeper/controllers/homepage.dart';

class HomepageView extends StatefulWidget {
  final HomepageController controller;

  const HomepageView({super.key, required this.controller});

  @override
  _HomepageViewState createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper Menu'),
      ),
      
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            _buildDifficultySelector(),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.controller.startGame(context);
              },
              child: const Text('Start Game'),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showRules,
              child: const Text('Game Rules'),
            
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return DropdownButton<String>(
      value: widget.controller.getSelectedDifficulty(),
      items: widget.controller.model.difficulties.map((String difficulty) {
        return DropdownMenuItem<String>(
          value: difficulty,
          child: Text(difficulty),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          widget.controller.selectDifficulty(newValue!);
        });
      },
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Minesweeper Rules'),
          content: const Text(
            'Minesweeper is a puzzle game where you have to clear a board without detonating any hidden mines.'
            '\n\nSelect a tile to reveal its contents. Numbers on the tiles indicate how many mines are adjacent to that tile.'
            '\n\nGood luck!',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}