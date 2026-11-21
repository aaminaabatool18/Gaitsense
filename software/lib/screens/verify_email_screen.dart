import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _sending) return;

    setState(() => _sending = true);

    try {
      await user.sendEmailVerification();

      if (!mounted) return;

      _message('Verification email sent. Check your inbox.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (error.code == 'too-many-requests') {
        _message('Please wait before requesting another email.');
      } else {
        _message('Could not send verification email.');
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _checking) return;

    setState(() => _checking = true);

    try {
      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (refreshedUser?.emailVerified == true) {
        // Force a new ID token containing the verified
        // email claim for Firestore Security Rules.
        await refreshedUser!.getIdToken(true);

        if (!mounted) return;

        // The Auth Gate will rebuild when the user
        // signs in again.
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _message('Email verified! Sign in to continue.');
      } else {
        _message('Email is not verified yet. Check your inbox.');
      }
    } on FirebaseAuthException {
      if (!mounted) return;
      _message('Unable to check verification. Try again.');
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: desktop ? 460 : 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _brand(),
                        const SizedBox(height: 30),
                        const Text(
                          'One more step.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verify your email to activate '
                          'your GaitSense account.',
                          style: TextStyle(
                            color: Color(0xFFBAC8D1),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _verificationCard(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF243F4A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.multiline_chart_rounded,
            color: Color(0xFF80D5CF),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'GaitSense',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_unread_outlined,
          size: 50,
          color: AppColors.teal,
        ),
        const SizedBox(height: 18),
        const Text(
          'Verify your email',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppColors.midnight,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'We need to confirm that you have access '
          'to your email address.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        SelectableText(
          email,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
          onPressed: _checking ? null : _checkVerification,
          child: _checking
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("I've Verified My Email"),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _sending ? null : _sendVerification,
          child: _sending
              ? const Text('Sending...')
              : const Text('Resend Verification Email'),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
