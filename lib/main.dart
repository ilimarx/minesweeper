import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:minesweeper/models/homepage_model.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/views/homepage_view.dart';
import 'package:minesweeper/routing/authentication_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Menu model and controller

    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AuthenticationWrapper(),
    );
  }
}
