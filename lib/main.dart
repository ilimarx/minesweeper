import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minesweeper/models/homepage_model.dart';
import 'package:minesweeper/controllers/homepage_controller.dart';
import 'package:minesweeper/views/homepage_view.dart';
import 'package:minesweeper/routing/authentication_wrapper.dart';
import 'package:minesweeper/views/profile_view.dart';

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

    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF576421),
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
            backgroundColor: Color(0xFF576421),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF576421),
            textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/profile': (context) => ProfileView(),
      },
    );
  }
}
