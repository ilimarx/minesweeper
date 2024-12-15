// Author: Andrii Bondarenko (xbonda06)

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
  int? userRank;
  bool isLoading = true;
  bool isFiltersVisible = false;

  final Map<String, dynamic> _filters = {
    'startDate': null as DateTime?,
    'endDate': null as DateTime?,
    'difficulty': null as int?,
    'result': null as String?,
    'reverseOrder': false,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Loads user profile data and games
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final loadedUser = await widget.controller.loadProfile();
    if (loadedUser != null) {
      final games = await widget.controller.loadUserGames(loadedUser.uid);
      final gamesData = widget.controller.groupUserGames(games);
      final rank = await widget.controller.getUserRank();
      setState(() {
        user = loadedUser;
        groupedGames = gamesData;
        userRank = rank;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Applies the filters set by the user
  void _applyFilters() async {
    widget.controller.filters = _filters;
    final filteredGames = await widget.controller.loadFilteredGames(user!.uid);
    setState(() {
      groupedGames = filteredGames;
      isFiltersVisible = false; // Collapse filters after applying
    });
  }

  // Resets all filters to their default values
  void _resetFilters() {
    setState(() {
      _filters['startDate'] = null;
      _filters['endDate'] = null;
      _filters['difficulty'] = null;
      _filters['result'] = null;
      _filters['reverseOrder'] = false;
      isFiltersVisible = false; // Collapse filters after resetting
    });
    _loadData();
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
          _buildFilters(),
          Expanded(child: _buildGamesList()),
        ],
      ),
    );
  }

  // Builds the profile header with rank, best time, and played games
  Widget _buildProfileHeader() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  width: 110,
                  child: _buildProfileStat('Rank', userRank?.toString() ?? '—')),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildProfileStat(
                    'Best Time',
                    user!.bestTime != -1
                        ? widget.controller.formatTime(user!.bestTime)
                        : '—'),
              ),
              Container(
                  margin: const EdgeInsets.only(right: 4.0),
                  width: 110,
                  child: _buildProfileStat(
                      'Played Games',
                      groupedGames.values
                          .fold(0, (sum, games) => sum + games.length)
                          .toString())),
            ],
          ),
        ],
      ),
    );
  }

  // Builds a profile statistic with a label and a value
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

  // Builds the filter section
  Widget _buildFilters() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isFiltersVisible = !isFiltersVisible;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filters", style: TextStyle(fontSize: 16)),
                Icon(
                  isFiltersVisible ? Icons.expand_less : Icons.expand_more,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 100),
          firstChild: SizedBox.shrink(),
          secondChild: Column(
            children: [
              // Filter controls (dropdowns, date pickers, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int?>(
                    hint: const Text("Difficulty"),
                    value: _filters['difficulty'],
                    items: [
                      DropdownMenuItem(value: -1, child: const Text("All")),
                      DropdownMenuItem(value: 5, child: const Text("Easy")),
                      DropdownMenuItem(value: 10, child: const Text("Medium")),
                      DropdownMenuItem(value: 20, child: const Text("Hard")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filters['difficulty'] = value;
                      });
                    },
                  ),
                  DropdownButton<String?>(
                    hint: const Text("Result"),
                    value: _filters['result'],
                    items: [
                      DropdownMenuItem(value: 'all', child: const Text("All")),
                      DropdownMenuItem(value: 'win', child: const Text("Win")),
                      DropdownMenuItem(value: 'lose', child: const Text("Lose")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filters['result'] = value;
                      });
                    },
                  ),
                ],
              ),
              // Buttons to apply or reset filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Reset Filters"),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text("Apply Filters"),
                  ),
                ],
              ),
            ],
          ),
          crossFadeState: isFiltersVisible
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }

  // Builds the games list grouped by date
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
