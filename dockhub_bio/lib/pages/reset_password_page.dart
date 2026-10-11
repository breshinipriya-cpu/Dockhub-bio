import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractQueryParams();
    });
  }

  void _extractQueryParams() {
    String token = '';
    String email = '';

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['token'] != null && (args['token'] as String).isNotEmpty) {
        token = args['token'].toString();
      }
      if (args['email'] != null && (args['email'] as String).isNotEmpty) {
        email = args['email'].toString();
      }
    }

    final baseUri = Uri.base;
    if (token.isEmpty) token = baseUri.queryParameters['token'] ?? '';
    if (email.isEmpty) email = baseUri.queryParameters['email'] ?? '';

    // Handle Flutter Web Hash routing fragment parameters (e.g. /#/reset-password?token=...&email=...)
    if ((token.isEmpty || email.isEmpty) && baseUri.fragment.contains('?')) {
      try {
        final fragmentUri = Uri.parse('http://localhost${baseUri.fragment}');
        if (token.isEmpty) token = fragmentUri.queryParameters['token'] ?? '';
        if (email.isEmpty) email = fragmentUri.queryParameters['email'] ?? '';
      } catch (_) {}
    }

    if (token.isNotEmpty) _tokenController.text = token;
    if (email.isNotEmpty) _emailController.text = email;
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submitReset() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your registered account email address.');
      return;
    }

    if (token.isEmpty) {
      setState(() => _errorMessage = 'A valid reset token is required. Please click the reset link sent to your email.');
      return;
    }

    if (newPassword.length < 4) {
      setState(() => _errorMessage = 'Password must be at least 4 characters long.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final res = await ApiService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        setState(() {
          _successMessage = res['message']?.toString() ?? 'Password reset successfully!';
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        setState(() {
          _errorMessage = res['message']?.toString() ?? 'Failed to reset password. Link may be invalid or expired.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not reach server. Please check backend connection.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTokenInUrl = _tokenController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('New Password')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020712), Color(0xFF072F2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                color: const Color(0xFF0C1821),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.key_rounded, size: 68, color: Colors.greenAccent),
                      const SizedBox(height: 18),
                      const Text('Set New Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter a new password for your account below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      if (!hasTokenInUrl)
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'The Reset Token is automatically provided when you click the reset link sent to your email.',
                                  style: TextStyle(color: Colors.amber, fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_rounded, color: Colors.greenAccent),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _tokenController,
                        decoration: InputDecoration(
                          labelText: 'Reset Token (Security Key)',
                          helperText: 'Auto-filled when opening the reset link in your email',
                          helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                          prefixIcon: const Icon(Icons.vpn_key_rounded, color: Colors.greenAccent),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_rounded, color: Colors.greenAccent),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.greenAccent),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onSubmitted: (_) => _loading ? null : _submitReset(),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                      ],

                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submitReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/forgot-password'),
                        child: const Text('Request New Reset Link', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
