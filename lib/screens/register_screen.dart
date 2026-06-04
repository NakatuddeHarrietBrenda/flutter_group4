import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    // Clear previous error
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().register(
          name: _nameController.text.trim(),
          emailOrContact: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      // Trigger registration success notification
      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        title: 'Account Created',
        message: 'Welcome to NutriBlend Haven! Your exclusive boutique account for ${_nameController.text.trim()} is ready.',
        type: 'success',
      );

      // Navigate to home, remove register from stack
      Navigator.of(context).pushReplacementNamed('/home');
    }
    // If !success the error is shown inline from the provider
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Brand mark ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.opacity,
                            color: Color(0xFFD4AF37), size: 30),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Heading ─────────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color(0xFFF5F5F0),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Join NutriBlend Haven for exclusive access',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Error Banner ────────────────────────────────────────
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        if (auth.errorMessage == null) return const SizedBox();
                        return _ErrorBanner(message: auth.errorMessage!);
                      },
                    ),

                    // ── Full Name ───────────────────────────────────────────
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _nameController,
                      hint: 'e.g. Sarah Nakato',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (v.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Email / Contact ─────────────────────────────────────
                    _buildLabel('Email or Phone Number'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _emailController,
                      hint: 'you@example.com or 07XXXXXXXX',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        // Allow email format OR phone-like format
                        final isEmail = RegExp(
                                r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$')
                            .hasMatch(v.trim());
                        final isPhone =
                            RegExp(r'^[0-9+\-\s]{7,15}$').hasMatch(v.trim());
                        if (!isEmail && !isPhone) {
                          return 'Enter a valid email or phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Password ────────────────────────────────────────────
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _passwordController,
                      hint: 'Minimum 8 characters',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white30,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (v.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Confirm Password ────────────────────────────────────
                    _buildLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _confirmPasswordController,
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white30,
                          size: 20,
                        ),
                        onPressed: () => setState(() =>
                            _confirmPasswordVisible = !_confirmPasswordVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),

                    // ── Submit Button ───────────────────────────────────────
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            // Disable button while loading (prevents duplicate requests)
                            onPressed: auth.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              disabledBackgroundColor:
                                  const Color(0xFFD4AF37).withOpacity(0.4),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 6,
                              shadowColor:
                                  const Color(0xFFD4AF37).withOpacity(0.3),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black),
                                    ),
                                  )
                                : const Text(
                                    'CREATE ACCOUNT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Continue as Guest Button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.setGuestMode();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Continuing as guest...'),
                                backgroundColor: Color(0xFFD4AF37),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4AF37),
                          side: const BorderSide(color: Color(0xFFD4AF37)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE AS GUEST',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Navigate to Login ───────────────────────────────────
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?  ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}

// ── Error Banner widget ────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.redAccent, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}