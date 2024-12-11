import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minesweeper/views/auth_view.dart';
import 'package:minesweeper/views/homepage_view.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/models/homepage_model.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final HomepageController homepageController = HomepageController(HomepageModel());
  final ValueNotifier<Widget> _currentView = ValueNotifier<Widget>(const CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentView.value = const AuthView();
      } else {
        _currentView.value = HomepageView(controller: homepageController);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Widget>(
      valueListenable: _currentView,
      builder: (context, view, child) {
        return Scaffold(body: Center(child: view));
      },
    );
  }
}
