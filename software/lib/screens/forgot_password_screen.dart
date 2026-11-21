import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gait_brand_panel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _submitted = false;

  Future<void> _sendResetEmail() async {
    if (_loading || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());

      if (!mounted) return;

      setState(() => _submitted = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      switch (error.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        default:
          message = 'Unable to send the reset email right now.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: desktop ? AppColors.background : AppColors.midnight,
      body: desktop ? SafeArea(child: _desktopLayout()) : _mobileLayout(),
    );
  }

  Widget _desktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(flex: 11, child: GaitBrandPanel()),
              const SizedBox(width: 48),
              Expanded(
                flex: 10,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _formCard(mobile: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileLayout() {
    return ColoredBox(
      color: AppColors.midnight,
      child: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _mobileBrand(),
                          const SizedBox(height: 30),
                          const Text(
                            'Account recovery.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Secure access to your GaitSense account.',
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
                            child: _formCard(mobile: true),
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
      ),
    );
  }

  Widget _mobileBrand() {
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

  Widget _formCard({required bool mobile}) {
    return _submitted ? _successContent() : _resetForm();
  }

  Widget _resetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 42, color: AppColors.teal),
          const SizedBox(height: 18),
          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered email address. '
            'We will send you instructions to reset '
            'your password.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Email address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _sendResetEmail(),
            decoration: const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address.';
              }

              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: _loading ? null : _sendResetEmail,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 17),
            label: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _successContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 48,
          color: AppColors.teal,
        ),
        const SizedBox(height: 20),
        const Text(
          'Check your inbox',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppColors.midnight,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'If an account is associated with that email, '
          'you should receive password-reset instructions.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Return to Sign In'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            setState(() => _submitted = false);
          },
          child: const Text('Try another email'),
        ),
      ],
    );
  }
}
