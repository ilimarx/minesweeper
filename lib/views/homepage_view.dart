import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/homepage_controller.dart';
import '../models/user_model.dart';
import '../theme/colors.dart';
import 'profile_view.dart';

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
        title: Text('Minesweeper Menu'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            iconSize: 36,
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/mine.svg',
              height: 300,
              width: 300,
            ),
            _buildDifficultySelector(),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                widget.controller.startGame(context); // Assuming startGame is managed by the controller
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
                child: const Text('Game Rules')
            ),
            const SizedBox(height: 9),
            ElevatedButton(
                onPressed: () { Navigator.pushNamed(context, '/leaderboard'); },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: Color(0xFF32361F)
                ),
                child: const Text('Leaderboard')
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
