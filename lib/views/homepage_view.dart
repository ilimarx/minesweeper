// Author: Ilia Markelov (xmarke00)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/homepage_controller.dart';
import '../models/user_model.dart';
import '../theme/colors.dart';
import 'profile_view.dart';

// A stateful widget representing the main menu of the Minesweeper app.
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
        title: Text('Minesweeper Menu'), // App bar with the title and profile navigation.
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            iconSize: 36,
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile'); // Navigate to the profile view.
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Minesweeper logo/image
            SvgPicture.asset(
              'assets/images/mine.svg',
              height: 300,
              width: 300,
            ),
            _buildDifficultySelector(), // Dropdown to select game difficulty.
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                widget.controller.startGame(context); // Start the game with the selected difficulty.
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
                onPressed: _showRules,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: Color(0xFF32361F)
                ),
                child: const Text('How to Play')
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/leaderboard'); // Navigate to the leaderboard view.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: Color(0xFF32361F),
              ),
              child: const Text('Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown for selecting the game difficulty level.
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
          widget.controller.selectDifficulty(newValue!); // Update the selected difficulty.
        });
      },
    );
  }

  // Dialog displaying Minesweeper rules.
  void _showRules() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
            'Minesweeper is a puzzle game where you have to clear a board without detonating any hidden mines.'
                '\n\n1. Tap a tile to reveal it.'
                '\n\n2. Numbers show how many mines are nearby.'
                '\n\n3. Use Flag Mode (button below) to mark tiles with mines.'
                '\n\n4. You can also set flags with the long press on tile, while outside of the Flag Mode.'
                '\n\n5. Win by revealing all tiles without mines, or lose if you tap a mine!',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the rules dialog.
              },
            ),
          ],
        );
      },
    );
  }
}
