import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/views/profile_view.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class HomepageView extends StatefulWidget {
  final HomepageController controller;
  final User user;

  const HomepageView({
    super.key,
    required this.controller,
    required this.user,
  });

  @override
  _HomepageViewState createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserService userService = UserService();
    UserModel? user = await userService.getUserData();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Minesweeper Menu')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            iconSize: 36,
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: _currentUser);
            }
          ),
        ],
        leading: IconButton(
            onPressed: _showRules,
            tooltip: 'Theme',
            icon: const Icon(Icons.palette_outlined),
            iconSize: 36
        ),
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
                widget.controller.startGame(context);
              },
              child: const Text('Start Game'),
            ),
            
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: _showRules,
              child: const Text('Game Rules'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE1E6C3),
                  foregroundColor: Color(0xFF32361F)
              )
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