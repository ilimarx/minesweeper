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
  int? userRank;
  int? playedGames;

  int? selectedDifficulty;

  int? displayedBestTime;

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
      final rank = await widget.controller.getUserRank(loadedUser.uid, null);
      final gamesCount = await widget.controller.getPlayedGamesCount(loadedUser.uid);
      setState(() {
        user = loadedUser;
        leaderboard = users;
        userRank = rank;
        playedGames = gamesCount;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changeDifficulty(int? difficulty) async {
    setState(() {
      selectedDifficulty = difficulty;
      isLoading = true;
    });

    final users = await widget.controller.loadLeaderboard(difficulty: difficulty);
    final rank = await widget.controller.getUserRank(user!.uid, difficulty);
    final bestTime = await widget.controller.getBestTimeForDifficulty(user!.uid, difficulty);

    setState(() {
      leaderboard = users;
      userRank = rank;
      displayedBestTime = bestTime;
      isLoading = false;
    });
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
          _buildDifficultySelector(),
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
              : const Icon(Icons.account_circle, size: 54),
          const SizedBox(height: 7),
          Text(user!.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 4.0),
                width: 110,
                child: _buildProfileStat('Rank', userRank?.toString() ?? '—')
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildProfileStat('Best Time', displayedBestTime != null
                    ? widget.controller.formatTime(displayedBestTime!)
                    : (user!.bestTime != -1
                    ? widget.controller.formatTime(user!.bestTime)
                    : '—')
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4.0),
                width: 110,
                child: _buildProfileStat(
                    'Played Games',
                    playedGames?.toString() ?? 'N/A'
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

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: selectedDifficulty == null
              ? null
              : () {
            final newDifficulty = selectedDifficulty == 5
                ? null
                : selectedDifficulty == 10
                ? 5
                : 10;
            _changeDifficulty(newDifficulty);
          },
        ),
        Text(
          selectedDifficulty == null
              ? "All"
              : selectedDifficulty == 5
              ? "Easy"
              : selectedDifficulty == 10
              ? "Medium"
              : "Hard",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: selectedDifficulty == 20
              ? null
              : () {
            final newDifficulty = selectedDifficulty == null
                ? 5
                : selectedDifficulty == 5
                ? 10
                : 20;
            _changeDifficulty(newDifficulty);
          },
        ),
      ],
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
            color: rank != userRank ? AppColors.primary : Color(0xFF899E34) ,
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
