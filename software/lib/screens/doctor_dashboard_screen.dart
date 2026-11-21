import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GaitSense Doctor')),
      body: Center(
        child: FilledButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
