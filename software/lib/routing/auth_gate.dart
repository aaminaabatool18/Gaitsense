import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../screens/login_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/caregiver_home_screen.dart';
import '../screens/doctor_dashboard_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

import '../screens/verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return const _StatusScreen(
            message: 'Unable to check your sign-in status.',
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }
        if (!firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }

        return _ProfileRouter(
          key: ValueKey(firebaseUser.uid),
          uid: firebaseUser.uid,
        );
      },
    );
  }
}

class _ProfileRouter extends StatefulWidget {
  final String uid;

  const _ProfileRouter({super.key, required this.uid});

  @override
  State<_ProfileRouter> createState() => _ProfileRouterState();
}

class _ProfileRouterState extends State<_ProfileRouter> {
  final _userService = UserService();
  late Future<AppUser?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _userService.getUserProfile(widget.uid);
  }

  void _retry() {
    setState(() {
      _profileFuture = _userService.getUserProfile(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return _StatusScreen(
            message: 'Could not load your GaitSense profile.',
            onRetry: _retry,
          );
        }

        final profile = snapshot.data;

        if (profile == null || profile.uid != widget.uid) {
          return const _StatusScreen(
            message: 'Your account does not have a valid profile yet.',
          );
        }

        switch (profile.role) {
          case 'patient':
            return const PatientHomeScreen();

          case 'caregiver':
            return const CaregiverHomeScreen();

          case 'doctor':
            return const DoctorDashboardScreen();

          case 'admin':
            return const AdminDashboardScreen();

          default:
            return const _StatusScreen(
              message: 'This account has an unsupported role.',
            );
        }
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _StatusScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _StatusScreen({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded, size: 44),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                if (onRetry != null)
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await AuthService().logout();
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
