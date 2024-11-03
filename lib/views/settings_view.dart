import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class SettingsView extends StatelessWidget {
  final UserModel user;

  const SettingsView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = ModalRoute.of(context)?.settings.arguments as UserModel?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,

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
            if (user.avatar.isNotEmpty)
              Image.network(user.avatar, height: 100, width: 100),
          ],
        ),
      ),
    );
  }
}
