// Author: Ilia Markelov (xmarke00)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import 'create_account_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});
  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final AuthController _authController = AuthController(); // Handles authentication logic
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input
  String? _errorMessage; // Stores error messages during authentication

  /// Attempts to sign in the user using provided credentials
  Future<void> _signIn() async {
    final user = await _authController.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (user == null) {
      setState(() {
        _errorMessage = "Failed to sign in. Please check your email or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In to Minesweeper'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Hides password input
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button to navigate to account creation screen
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountView(),
                      ),
                    );
                  },
                  child: Text('Create Account'),
                  style: TextButton.styleFrom(
                    fixedSize: Size(screenWidth * 0.4, 36),
                    backgroundColor: Color(0xFFE1E6C3),
                    foregroundColor: Color(0xFF32361F),
                  ),
                ),
                // Button to trigger sign-in action
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth * 0.4, 36),
                  ),
                ),
              ],
            ),
            // Display error message if any
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
