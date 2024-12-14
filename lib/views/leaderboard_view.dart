import 'package:flutter/material.dart';
import 'package:minesweeper/controllers/leaderboard_controller.dart';
import 'package:minesweeper/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../theme/colors.dart';

class LeaderboardView extends StatefulWidget {
  final LeaderboardController controller;

  LeaderboardView({super.key, required this.controller});

  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  UserModel? user;
  List<UserModel> leaderboard = [];
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
      final users = await widget.controller.loadLeaderboard();
      setState(() {
        user = loadedUser;
        leaderboard = users;
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
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('No user data found.'))
          : Column(
        children: [
          _buildProfileHeader(),
          Expanded(child: _buildLeaderboard()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          user!.avatar.isNotEmpty
              ? CircleAvatar(radius: 27, backgroundImage: NetworkImage(user!.avatar))
              : const Icon(Icons.account_circle, size: 90),
          const SizedBox(height: 7),
          Text(user!.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 4.0),
                width: 110,
                child: _buildProfileStat('Rank', user!.playedGames.toString())
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildProfileStat('Best Time', widget.controller.formatTime(user!.bestTime)),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4.0),
                width: 110,
                child: _buildProfileStat(
                    'Played Games',
                    '0'
                )
              ),
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


  Widget _buildLeaderboard() {
    return ListView.builder(
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index];
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              CircleAvatar(
                radius: 18,
                backgroundImage: user.avatar.isNotEmpty
                    ? NetworkImage(user.avatar)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),

              Expanded(
                child: Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: Text(
                  widget.controller.formatTime(user.bestTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
