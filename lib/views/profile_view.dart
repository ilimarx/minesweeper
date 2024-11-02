import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),


      body: Center(
        child: const Text('This is the Profile Page'),
      ),
    );
  }
}
