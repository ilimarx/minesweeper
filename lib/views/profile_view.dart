import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  final ProfileController controller;

  ProfileView({super.key, required this.controller});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await widget.controller.loadUserProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.userModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFFE1E6C3),
        title: const Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 36,
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/profile/settings',
                  arguments: user.uid
                );
              }
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xFFE1E6C3),
            borderRadius: BorderRadius.only(
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
                  // Rank
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Rank:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                        Text(user.playedGames.toString(), style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 30),

                  // Best Time
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text('Best Time:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                        Text('${user.bestTime}s', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  // Played Games

                  const SizedBox(width: 30),

                  Expanded(
                    child: Column(
                      children: [
                        const Text('Played Games:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                        Text(user.playedGames.toString(), style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
