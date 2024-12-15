import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minesweeper/controllers/leaderboard_controller.dart';
import 'package:minesweeper/controllers/profile_controller.dart';

import 'package:minesweeper/models/homepage_model.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/models/user_model.dart';
import 'package:minesweeper/theme/colors.dart';
import 'package:minesweeper/views/homepage_view.dart';
import 'package:minesweeper/routing/authentication_wrapper.dart';
import 'package:minesweeper/views/leaderboard_view.dart';
import 'package:minesweeper/views/profile_view.dart';
import 'package:minesweeper/views/settings_view.dart';

import 'controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Menu model and controller
    final screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold
          ),
          titleLarge: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
          titleMedium: GoogleFonts.roboto(),
          titleSmall: GoogleFonts.roboto(),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/profile': (context) {
          final profileController = ProfileController();
          return ProfileView(controller: profileController);
        },
        '/profile/settings': (context) {
          final uid = ModalRoute.of(context)!.settings.arguments as String;
          final settingsController = SettingsController();
          return SettingsView(settingsController: settingsController, userId: uid);
        },
        '/leaderboard': (context) {
          final leaderboardController = LeaderboardController();
          return LeaderboardView(controller: leaderboardController);
        }
      },
    );
  }
}
