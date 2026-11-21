import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GaitSense Caregiver')),
      body: Center(
        child: FilledButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
