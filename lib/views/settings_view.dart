// Author: Andrii Bondarenko (xbonda06)

import 'package:flutter/material.dart';
import 'package:minesweeper/controllers/auth_controller.dart';
import 'package:minesweeper/controllers/settings_controller.dart';
import '../controllers/profile_controller.dart';
import '../theme/colors.dart';

class SettingsView extends StatefulWidget {
  final SettingsController settingsController;
  final String userId;

  SettingsView({super.key, required this.settingsController, required this.userId});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load the user's profile data into the text fields on initialization
    widget.settingsController.loadUserProfile().then((_) {
      setState(() {
        _usernameController.text = widget.settingsController.userModel?.username ?? '';
        _avatarController.text = widget.settingsController.userModel?.avatar ?? '';
      });
    });
  }

  // Save changes to the user's profile in Firestore
  Future<void> _saveChanges() async {
    final newUsername = _usernameController.text.trim();

    if (await widget.settingsController.isUsernameTaken(newUsername) &&
        newUsername != widget.settingsController.userModel?.username) {
      setState(() {
        _errorMessage = 'This username is already taken.';
      });
      return;
    }

    await widget.settingsController.updateUserProfile(
      uid: widget.userId,
      username: newUsername,
      avatarUrl: _avatarController.text.trim(),
    );
    Navigator.pop(context, true); // Return to the previous screen
  }

  // Log out the user and redirect to the login page
  void _signOut() async {
    await widget.settingsController.signOut();
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
            // Input field for username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _errorMessage,
              ),
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            // Input field for avatar URL
            TextField(
              controller: _avatarController,
              decoration: InputDecoration(labelText: 'Avatar URL'),
            ),
            const SizedBox(height: 20),
            // Button to save changes
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
            Spacer(),
            // Button to sign out
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBA1A1A),
                minimumSize: Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
