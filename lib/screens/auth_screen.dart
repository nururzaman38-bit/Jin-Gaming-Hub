import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

/// Screen 2: Authentication Screen (Login / Sign Up)
/// - Tabs for Login and Register
/// - Email/Password fields
/// - Google Sign-In button
/// - Forgot Password modal
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login fields
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Register fields
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();
  final _regDisplayNameCtrl = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    _regDisplayNameCtrl.dispose();
    super.dispose();
  }

  // ── Login ───────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPasswordCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      AppRoutes.pushReplacement(context, AppRoutes.home);
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  // ── Register ────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _regEmailCtrl.text.trim(),
      password: _regPasswordCtrl.text,
      displayName: _regDisplayNameCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      AppRoutes.pushReplacement(context, AppRoutes.home);
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  // ── Google Sign-In ──────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (!mounted) return;
    if (success) {
      AppRoutes.pushReplacement(context, AppRoutes.home);
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  // ── Forgot Password ─────────────────────────────────────
  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a reset link.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;
              final auth = context.read<AuthProvider>();
              final success =
                  await auth.sendPasswordReset(emailCtrl.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  _showSuccess('Password reset email sent!');
                } else if (auth.error != null) {
                  _showError(auth.error!);
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // ── SnackBar Helpers ────────────────────────────────────
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Logo ──────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      size: 40,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jin Gaming Hub',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tab Bar ──────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: AppTheme.textPrimary,
                      unselectedLabelColor: AppTheme.textSecondary,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Register'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Tab Views ────────────────────────────
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(),
                        _buildRegisterForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Login Form ──────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _obscureLoginPassword,
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureLoginPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  // ── Register Form ───────────────────────────────────────
  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _regDisplayNameCtrl,
            validator: Validators.displayName,
            decoration: const InputDecoration(
              hintText: 'Display Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regPasswordCtrl,
            obscureText: _obscureRegPassword,
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureRegPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscureRegPassword = !_obscureRegPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regConfirmPasswordCtrl,
            obscureText: _obscureRegConfirm,
            validator: (v) => Validators.confirmPassword(
                v, _regPasswordCtrl.text),
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureRegConfirm
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _obscureRegConfirm = !_obscureRegConfirm),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleRegister,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Register'),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  // ── Shared Widgets ──────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.textSecondary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: Image.asset(
          'assets/images/google_logo.png',
          width: 24,
          height: 24,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.login, color: AppTheme.textPrimary),
        ),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
