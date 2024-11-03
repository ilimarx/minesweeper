import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';

class ProfileView extends StatelessWidget {
  final UserModel user;

  const ProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFFE1E6C3),
        title: const Text('Profile'),
        centerTitle: true,
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
                  Column(
                    children: [
                      const Text('Rank:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                      Text(user.playedGames.toString(), style: const TextStyle(fontSize: 18)),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // Best Time
                  Column(
                    children: [
                      const Text('Best Time:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                      Text('${user.bestTime}s', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  // Played Games
                  const Spacer(flex: 3),

                  Column(
                    children: [
                      const Text('Played Games:', style: TextStyle(fontSize: 16, color: Color(0xFF77786A), fontWeight: FontWeight.w400)),
                      Text(user.playedGames.toString(), style: const TextStyle(fontSize: 18)),
                    ],
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
