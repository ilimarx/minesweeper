import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller;

  ProfileView({super.key, required this.controller});

  Future<UserModel?> _loadProfile() async {
    await controller.loadUserProfile();
    return controller.userModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFFE1E6C3),
        title: const Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 36,
            tooltip: 'Settings',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/profile/settings',
                arguments: controller.userModel?.uid,
              );
              if (result == true) {
                _loadProfile();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final user = snapshot.data!;
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: Color(0xFFE1E6C3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  user.avatar != ''
                      ? CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(user.avatar),
                  )
                      : const Icon(Icons.account_circle, size: 90),
                  const SizedBox(height: 7),
                  Text(
                    user.username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProfileStat('Rank', user.playedGames.toString()),
                      const SizedBox(width: 30),
                      _buildProfileStat('Best Time', '${user.bestTime}s'),
                      const SizedBox(width: 30),
                      _buildProfileStat('Played Games', user.playedGames.toString()),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF77786A))),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

