import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../theme/colors.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller;

  ProfileView({super.key, required this.controller});

  Future<UserModel?> _loadProfile() async {
    await controller.loadUserProfile();
    return controller.userModel;
  }

  Future<List<Map<String, dynamic>>> _loadUserGames(String userId) async {
    return await controller.loadUserGames(userId);
  }

  String formatTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return '${timeInSeconds}s';
    }
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes}m ${seconds}s';
  }


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
          return Column(
            children: [
              _buildProfileHeader(user),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadUserGames(user.uid),
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

                    final games = gamesSnapshot.data!;
                    return ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        final isWin = game['result'] == 'win';
                        final difficulty = game['mines'] == 5 ? 'Easy' : game['mines'] == 20 ? 'Hard' : 'Medium';
                        final time = game['time'] ?? 0;
                        final reverseIndex = games.length - index;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          padding: const EdgeInsets.all(8),
                          height: 39,
                          decoration: BoxDecoration(
                            color: isWin ? AppColors.primary : AppColors.error,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: 6.0),
                                  width: 80,
                                  child: Text(
                                      '$reverseIndex',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.left)
                              ),

                              Text(difficulty, style: const TextStyle(color: Colors.white, fontSize: 16)),

                              Container(
                                margin: EdgeInsets.only(right: 6.0),
                                width: 80,
                                child: Text(
                                    formatTime(time),
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    textAlign: TextAlign.right)
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
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
                _buildProfileStat('Best Time', user.bestTime == -1 ? '—' : formatTime(user.bestTime)),
                const SizedBox(width: 30),
                FutureBuilder<int>(
                  future: controller.getPlayedGamesCount(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('...');
                    }
                    if (snapshot.hasError) {
                      return const Text('Error');
                    }
                    final playedGamesCount = snapshot.data ?? 0;
                    return _buildProfileStat('Played Games', playedGamesCount.toString());
                  },
                ),
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
