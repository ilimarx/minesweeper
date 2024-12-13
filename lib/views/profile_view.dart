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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final loadedUser = await widget.controller.loadProfile();
    if (loadedUser != null) {
      final gamesData = await widget.controller.groupUserGamesWithIndices(loadedUser.uid);
      setState(() {
        user = loadedUser;
        groupedGames = gamesData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
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
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/profile/settings',
                arguments: user?.uid,
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('No user data found.'))
          : Column(
        children: [
          _buildProfileHeader(),
          Expanded(child: _buildGamesList()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
          user!.avatar.isNotEmpty
              ? CircleAvatar(radius: 45, backgroundImage: NetworkImage(user!.avatar))
              : const Icon(Icons.account_circle, size: 90),
          const SizedBox(height: 7),
          Text(user!.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileStat('Rank', user!.playedGames.toString()),
              const SizedBox(width: 30),
              _buildProfileStat('Best Time', widget.controller.formatTime(user!.bestTime)),
              const SizedBox(width: 30),
              _buildProfileStat('Played Games', groupedGames.values.fold(0, (sum, games) => sum + games.length).toString()),
            ],
          ),
        ],
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
    return ListView(
      children: groupedGames.entries.map((entry) {
        final date = entry.key;
        final games = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...games.map((game) {
              final isWin = game['result'] == 'win';
              final difficulty = game['mines'] == 5
                  ? 'Easy'
                  : game['mines'] == 20
                  ? 'Hard'
                  : 'Medium';
              final time = game['time'] ?? 0;
              final index = game['index'];

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
                        '$index',
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
      }).toList(),
    );
  }
}
