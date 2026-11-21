import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gait_brand_panel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _detailsFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _authService = AuthService();
  final _userService = UserService();

  int _step = 0;
  String _role = 'patient';

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (_detailsFormKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    setState(() => _step = 0);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    if (_loading || !_securityFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    User? createdUser;

    try {
      final credential = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      createdUser = credential.user;

      if (createdUser == null) {
        throw StateError('Firebase did not return a user.');
      }

      final profile = AppUser(
        uid: createdUser.uid,
        fullName: _nameController.text.trim(),
        email: createdUser.email ?? _emailController.text.trim(),
        role: _role,
        createdAt: DateTime.now(),
      );

      await _userService.createUserProfile(profile);
      try {
        await createdUser.sendEmailVerification();
      } on FirebaseAuthException catch (error) {
        debugPrint('Verification email could not be sent: ${error.code}');
      }
      if (!mounted) return;

      _showMessage('Your GaitSense account has been created.');

      // Dashboard routing will be implemented next.
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      switch (error.code) {
        case 'email-already-in-use':
          _showMessage('This email is already registered.');
          break;
        case 'weak-password':
          _showMessage('Choose a stronger password.');
          break;
        case 'invalid-email':
          _showMessage('Enter a valid email address.');
          break;
        case 'network-request-failed':
          _showMessage('Check your internet connection.');
          break;
        default:
          _showMessage('Registration failed: ${error.code}');
      }
    } catch (error) {
      if (!mounted) return;

      // Firebase Auth may have succeeded even if the
      // Firestore profile write failed. Do not pretend
      // that the account was fully created.
      _showMessage(
        'Registration could not be completed. '
        'The login account may exist; please do not '
        'register again until we check your Firebase records.',
      );

      debugPrint('GaitSense registration error: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: desktop ? AppColors.background : AppColors.midnight,
      resizeToAvoidBottomInset: true,
      body: desktop ? SafeArea(child: _desktopLayout()) : _mobileLayout(),
    );
  }

  // -----------------------------------------------
  // DESKTOP
  // -----------------------------------------------

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
                    child: SingleChildScrollView(
                      child: _signupContent(mobile: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------
  // MOBILE
  // -----------------------------------------------

  Widget _mobileLayout() {
    return ColoredBox(
      color: AppColors.midnight,
      child: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shortScreen = constraints.maxHeight < 680;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: shortScreen ? 12 : 22,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _signupContent(mobile: true, compact: shortScreen),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------
  // PAGE CONTENT
  // -----------------------------------------------

  Widget _signupContent({required bool mobile, bool compact = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mobile) ...[
          _mobileBrand(),
          SizedBox(height: compact ? 14 : 28),
          Text(
            _step == 0 ? 'Join GaitSense.' : 'Secure your account.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 25 : 31,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _step == 0
                ? 'Your journey to better movement insights.'
                : 'One final step to get started.',
            style: const TextStyle(color: Color(0xFFBAC8D1), fontSize: 13),
          ),
          SizedBox(height: compact ? 14 : 24),
        ],

        Container(
          padding: EdgeInsets.all(mobile ? (compact ? 18 : 22) : 0),
          decoration: mobile
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _progressHeader(),
              SizedBox(height: compact ? 16 : 24),

              if (_step == 0) _personalDetails() else _accountSecurity(),

              SizedBox(height: compact ? 14 : 22),

              if (_step == 0)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                  ),
                  onPressed: _nextStep,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Continue'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                )
              else ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                  ),
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _loading ? null : _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('Back to details'),
                ),
              ],

              if (_step == 0) ...[
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileBrand() {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
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

  // -----------------------------------------------
  // STEP INDICATOR
  // -----------------------------------------------

  Widget _progressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _step == 0 ? 'Personal details' : 'Account security',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.midnight,
              ),
            ),
            Text(
              '${_step + 1} of 2',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _progressBar(active: true)),
            const SizedBox(width: 8),
            Expanded(child: _progressBar(active: _step == 1)),
          ],
        ),
      ],
    );
  }

  Widget _progressBar({required bool active}) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: active ? AppColors.teal : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // -----------------------------------------------
  // STEP 1 — PERSONAL DETAILS
  // -----------------------------------------------

  Widget _personalDetails() {
    return Form(
      key: _detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Full name'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              final name = value?.trim() ?? '';

              if (name.isEmpty) return 'Full name is required.';
              if (name.length > 100) {
                return 'Name must be 100 characters or fewer.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),

          _label('Email address'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
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
          const SizedBox(height: 16),

          _label('Register as'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'patient', child: Text('Patient')),
              DropdownMenuItem(
                value: 'caregiver',
                child: Text('Caregiver / Family Member'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _role = value);
              }
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------
  // STEP 2 — SECURITY
  // -----------------------------------------------

  Widget _accountSecurity() {
    return Form(
      key: _securityFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create a secure password for your account.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          _label('Password'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              hintText: 'At least 8 characters',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Use at least 8 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _label('Confirm password'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _confirmController,
            obscureText: _hideConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _register(),
            decoration: InputDecoration(
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.shield_outlined),
              suffixIcon: IconButton(
                tooltip: _hideConfirm ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _hideConfirm = !_hideConfirm);
                },
                icon: Icon(
                  _hideConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.teal, size: 17),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your password is managed securely through Firebase Authentication.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.midnight,
      ),
    );
  }
}
