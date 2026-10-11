import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email.trim());
  }

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter (A-Z).';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter (a-z).';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least one number (0-9).';
    }
    if (!RegExp(r"[!@#$%^&*()_+\-=\[\]{};':\\|,.<>\/?~]").hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$%^&*).';
    }
    return null;
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    if (!_validateEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address (e.g. user@example.com).');
      return;
    }

    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      setState(() => _errorMessage = passwordError);
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await ApiService.signup(name: name, email: email, password: password);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _successMessage = 'Account created successfully.');
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        setState(() => _errorMessage = (result['message'] ?? 'Unable to create account.').toString());
      }
    } catch (_) {
      setState(() => _errorMessage = 'Unable to connect to the analysis server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020712), Color(0xFF062F2B), Color(0xFF020712)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: const Color(0xFF0C1821),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_add_alt_rounded, size: 68, color: Colors.greenAccent),
                        const SizedBox(height: 18),
                        const Text('Sign Up', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          decoration: _inputDecoration('Full Name', Icons.person_rounded),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email', Icons.email_rounded),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration('Password', Icons.lock_rounded, suffix: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                          )),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: _inputDecoration('Confirm Password', Icons.lock_rounded, suffix: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(_obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                          )),
                        ),
                        const SizedBox(height: 18),
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
                              color: Colors.red.withValues(alpha: 0.08),
                            ),
                            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                          ),
                        if (_successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
                              color: Colors.greenAccent.withValues(alpha: 0.08),
                            ),
                            child: Text(_successMessage!, style: const TextStyle(color: Colors.greenAccent)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.greenAccent),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
