// settings_view.dart
import 'package:flutter/material.dart';
import 'package:minesweeper/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class SettingsView extends StatefulWidget {
  final ProfileController profileController;

  SettingsView({super.key, required this.profileController});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.profileController.loadUserProfile().then((_) {
      setState(() {
        _usernameController.text = widget.profileController.userModel?.username ?? '';
        _avatarController.text = widget.profileController.userModel?.avatar ?? '';
      });
    });
  }

  Future<void> _saveChanges() async {
    await widget.profileController.updateUserProfile(
      username: _usernameController.text.trim(),
      avatarUrl: _avatarController.text.trim(),
    );
    Navigator.pop(context);
  }

  void _signOut() async {
    await widget.profileController.signOut();
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
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _avatarController,
              decoration: InputDecoration(labelText: 'Avatar URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
            Spacer(),
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
