import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import 'register_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  bool _isLoading = false;

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
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call for reset
    await Future.delayed(const Duration(seconds: 1500));

    if (!mounted) return;

    final input = _emailOrPhoneController.text.trim();
    
    // Trigger global notification
    Provider.of<NotificationProvider>(context, listen: false).addNotification(
      title: 'Reset Link Dispatched',
      message: 'A secure password recovery link has been sent to $input.',
      type: 'info',
    );

    setState(() {
      _isLoading = false;
    });

    // Navigate back to Login Screen after a short delay
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                    const SizedBox(height: 40),

                    // Brand mark / Lock Icon
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: Color(0xFFD4AF37), size: 36),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Heading
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Reset Password',
                            style: TextStyle(
                              color: Color(0xFFF5F5F0),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email or phone number to receive a reset link',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Label
                    Text(
                      'Email or Phone Number',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email / Phone Field
                    TextFormField(
                      controller: _emailOrPhoneController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        final isEmail = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(v.trim());
                        final isPhone = RegExp(r'^[0-9+\-\s]{7,15}$').hasMatch(v.trim());
                        if (!isEmail && !isPhone) {
                          return 'Enter a valid email or phone number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'you@example.com or 07XXXXXXXX',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                        prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFFD4AF37), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
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
                    ),
                    const SizedBox(height: 36),

                    // Reset Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                'SEND RESET LINK',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navigation Back
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remembered your password? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Create New Account',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
