import 'package:flutter/material.dart';
import 'package:minesweeper/models/models.dart';
import 'package:minesweeper/controllers/homepage.dart';
import 'package:minesweeper/views/homepage.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Menu model and controller
    final homepageModel = HomepageModel();
    final homepageController = HomepageController(homepageModel);

    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomepageView(controller: homepageController),
    );
  }
}
