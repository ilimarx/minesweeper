// Author: Ilia Markelov (xmarke00)

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class CreateAccountView extends StatefulWidget {
  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  // Instance of AuthController to handle authentication logic
  final AuthController _authController = AuthController();

  // Controllers for user input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  // To store error message if account creation fails
  String? _errorMessage;

  // Handles account creation using email, password, and username
  Future<void> _createAccount() async {
    final user = await _authController.createAccountWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
    );

    if (user == null) {
      // Update error message state if creation fails
      setState(() {
        _errorMessage = "Failed to create account. Please try again.";
      });
    } else {
      // Navigate back if account creation is successful
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Username input field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            // Email input field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Hides the password input
            ),
            const SizedBox(height: 20),
            // Button to trigger account creation
            ElevatedButton(
              onPressed: _createAccount,
              child: const Text('Create Account'),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(165, 36),
                backgroundColor: const Color(0xFFE1E6C3),
                foregroundColor: const Color(0xFF32361F),
              ),
            ),
            // Displays error message if any
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
