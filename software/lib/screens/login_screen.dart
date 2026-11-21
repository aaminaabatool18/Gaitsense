import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gait_brand_panel.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _hidePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed in successfully.')));

      // Role-based routing will be connected later.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      switch (error.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Incorrect email or password.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Unable to sign in. Please try again.';
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.background : AppColors.midnight,
      resizeToAvoidBottomInset: true,
      body: isDesktop
          ? SafeArea(child: _buildDesktopLayout())
          : _buildMobileLayout(),
    );
  }

  // --------------------------------------------------
  // DESKTOP LAYOUT — ORIGINAL DESIGN
  // --------------------------------------------------

  Widget _buildDesktopLayout() {
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
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildLoginForm(isMobile: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MOBILE LAYOUT — FULL-SCREEN MIDNIGHT
  // --------------------------------------------------

  Widget _buildMobileLayout() {
    return ColoredBox(
      color: AppColors.midnight,
      child: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final isShort = height < 760;
              final isVeryShort = height < 640;

              final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

              final sidePadding = constraints.maxWidth < 360 ? 16.0 : 24.0;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: isVeryShort ? 12 : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMobileHeader(isShort),

                            SizedBox(
                              height: isVeryShort
                                  ? 14
                                  : isShort
                                  ? 24
                                  : 36,
                            ),

                            _buildMobileIntroduction(isShort),

                            SizedBox(
                              height: isVeryShort
                                  ? 14
                                  : isShort
                                  ? 20
                                  : 28,
                            ),

                            Container(
                              padding: EdgeInsets.all(isVeryShort ? 18 : 24),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: _buildLoginForm(
                                isMobile: true,
                                compact: isShort,
                              ),
                            ),

                            if (!isShort && !keyboardOpen) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'MONITOR  ·  UNDERSTAND  ·  SUPPORT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF9DB1BF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
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

  // --------------------------------------------------
  // MOBILE HEADER
  // --------------------------------------------------

  Widget _buildMobileHeader(bool compact) {
    return Row(
      children: [
        Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GaitSense',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 21 : 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            if (!compact)
              const Text(
                'GAIT MONITORING SYSTEM',
                style: TextStyle(
                  color: Color(0xFF9DB1BF),
                  fontSize: 9,
                  letterSpacing: 1.4,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------
  // MOBILE INTRODUCTION
  // --------------------------------------------------

  Widget _buildMobileIntroduction(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back.',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 27 : 33,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your movement insights start here.',
          style: TextStyle(color: Color(0xFFBAC8D1), fontSize: 13),
        ),
        SizedBox(height: compact ? 12 : 20),
        SizedBox(
          height: compact ? 32 : 55,
          width: double.infinity,
          child: CustomPaint(painter: GaitWavePainter()),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SHARED LOGIN FORM
  // --------------------------------------------------

  Widget _buildLoginForm({required bool isMobile, bool compact = false}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isMobile ? 'Sign in' : 'Welcome back',
            style: TextStyle(
              fontSize: isMobile ? 23 : 30,
              fontWeight: FontWeight.w700,
              color: AppColors.midnight,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isMobile
                ? 'Access your GaitSense account'
                : 'Sign in to access your GaitSense account.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: compact ? 16 : 26),

          const Text(
            'Email address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Email address is required.';
              }

              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address.';
              }

              return null;
            },
          ),

          SizedBox(height: compact ? 12 : 18),

          const Text(
            'Password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onFieldSubmitted: (_) {
              if (!_isLoading) _login();
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required.';
              }

              return null;
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
              child: const Text('Forgot password?'),
            ),
          ),

          SizedBox(height: compact ? 6 : 12),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isMobile ? AppColors.teal : AppColors.midnight,
            ),
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sign In'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),

          SizedBox(height: compact ? 10 : 16),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'New to GaitSense?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                child: const Text('Create account'),
              ),
            ],
          ),

          if (!isMobile) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Secure account authentication',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
