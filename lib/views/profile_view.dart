import 'package:flutter/material.dart';
import 'package:minesweeper/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../theme/colors.dart';

class ProfileView extends StatefulWidget {
  final ProfileController controller;

  ProfileView({super.key, required this.controller});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? user;
  Map<String, List<Map<String, dynamic>>> groupedGames = {};
  bool isLoadingProfile = true;
  bool isLoadingGames = true;
  int playedGamesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoadingProfile = true;
      isLoadingGames = true;
    });

    final loadedUser = await widget.controller.loadProfile();
    if (loadedUser != null) {
      final gamesData = await widget.controller.groupUserGamesByDate(loadedUser.uid);
      setState(() {
        user = loadedUser;
        groupedGames = gamesData;
        playedGamesCount = groupedGames.values.fold(0, (sum, games) => sum + games.length);
        isLoadingProfile = false;
        isLoadingGames = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
        isLoadingGames = false;
      });
    }
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
                arguments: user?.uid,
              );
              if (result == true) {
                _loadProfileData();
              }
            },
          ),
        ],
      ),
      body: isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('No user data found.'))
          : Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: isLoadingGames
                ? const Center(child: CircularProgressIndicator())
                : groupedGames.isEmpty
                ? const Center(child: Text('No games found.'))
                : _buildGamesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFE1E6C3),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            user!.avatar != ''
                ? CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(user!.avatar),
            )
                : const Icon(Icons.account_circle, size: 90),
            const SizedBox(height: 7),
            Text(
              user!.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileStat('Rank', user!.playedGames.toString()),
                const SizedBox(width: 30),
                _buildProfileStat('Best Time',
                    user!.bestTime == -1 ? '—' : widget.controller.formatTime(user!.bestTime)),
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

  Widget _buildGamesList() {
    int globalIndex = playedGamesCount;
    return ListView.builder(
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
                        widget.controller.formatTime(time),
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
    );
  }
}
