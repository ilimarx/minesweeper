import 'package:flutter/material.dart';
import 'package:minesweeper/models/common_models.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/views/homepage_view.dart';

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
        primarySwatch: Colors.green,
      ),
      home: HomepageView(controller: homepageController),
    );
  }
}
