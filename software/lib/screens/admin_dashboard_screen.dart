import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GaitSense Administrator')),
      body: Center(
        child: FilledButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
