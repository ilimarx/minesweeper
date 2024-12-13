import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../theme/colors.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller;

  ProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
                controller.loadProfile();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: controller.loadProfile(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileSnapshot.hasError) {
            return Center(child: Text('Error loading profile: ${profileSnapshot.error}'));
          }
          if (!profileSnapshot.hasData || profileSnapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final user = profileSnapshot.data!;
          return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
            future: controller.groupUserGamesByDate(user.uid),
            builder: (context, gamesSnapshot) {
              if (gamesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (gamesSnapshot.hasError) {
                return Center(child: Text('Error loading games: ${gamesSnapshot.error}'));
              }
              if (!gamesSnapshot.hasData || gamesSnapshot.data!.isEmpty) {
                return const Center(child: Text('No games found.'));
              }

              final groupedGames = gamesSnapshot.data!;
              int globalIndex = groupedGames.values.fold(0, (sum, games) => sum + games.length);

              return Column(
                children: [
                  _buildProfileHeader(user, globalIndex),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groupedGames.keys.length,
                      itemBuilder: (context, dateIndex) {
                        final date = groupedGames.keys.toList()[dateIndex];
                        final games = groupedGames[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...games.map((game) {
                              final isWin = game['result'] == 'win';
                              final difficulty = game['mines'] == 5
                                  ? 'Easy'
                                  : game['mines'] == 20
                                  ? 'Hard'
                                  : 'Medium';
                              final time = game['time'] ?? 0;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isWin ? AppColors.primary : AppColors.error,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 6.0),
                                      width: 80,
                                      child: Text(
                                        '${globalIndex--}',
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Text(
                                      difficulty,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 6.0),
                                      width: 80,
                                      child: Text(
                                        controller.formatTime(time),
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, int playedGamesCount) {
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
        margin: const EdgeInsets.only(bottom: 8.0),
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
                _buildProfileStat('Best Time', user.bestTime == -1 ? '—' : controller.formatTime(user.bestTime)),
                const SizedBox(width: 30),
                _buildProfileStat('Played Games', '$playedGamesCount'),
              ],
            ),
          ],
        ),
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
