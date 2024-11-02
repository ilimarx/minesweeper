import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';

class ProfileView extends StatelessWidget {
  final UserModel user;

  const ProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = ModalRoute.of(context)?.settings.arguments as UserModel?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,

        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 32,
              tooltip: 'Settings',
              onPressed: () {
                Navigator.pushNamed(context, '/profile/settings', arguments: user);
              }
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('No user data available'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user.username}', style: TextStyle(fontSize: 20)),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
                  Text('Best Time: ${user.bestTime}', style: TextStyle(fontSize: 20)),
                  if (user.avatarUrl.isNotEmpty)
                    Image.network(user.avatarUrl, height: 100, width: 100),
          ],
        ),
      ),
    );
  }
}
