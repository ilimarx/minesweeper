// settings_view.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

class SettingsView extends StatelessWidget {
  final UserModel user;
  final AuthController _authController = AuthController();

  SettingsView({super.key, required this.user});

  void _signOut(BuildContext context) async {
    await _authController.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user.username}', style: TextStyle(fontSize: 20)),
            Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
            Text('Best Time: ${user.bestTime}', style: TextStyle(fontSize: 20)),
            if (user.avatar.isNotEmpty)
              Image.network(user.avatar, height: 100, width: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBA1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
