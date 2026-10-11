import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedServerUrl();
  }

  Future<void> _loadSavedServerUrl() async {
    final saved = await StorageService.loadServerUrl();
    if (saved != null && saved.isNotEmpty) {
      ApiService.baseUrl = saved;
    }
  }

  Future<void> _showServerConfigDialog() async {
    final controller = TextEditingController(text: ApiService.baseUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your computer\'s local network IP URL (e.g. http://172.23.53.44:8000 or http://10.0.2.2:8000):',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl.isNotEmpty) {
      ApiService.baseUrl = newUrl;
      await StorageService.saveServerUrl(newUrl);
      setState(() => _errorMessage = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server URL set to $newUrl')),
        );
      }
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email and password are required.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.login(email: email, password: password);
      if (!mounted) return;

      if (result['success'] == true) {
        final userName = (result['name'] ?? email).toString();
        final userEmail = (result['email'] ?? email).toString();
        await StorageService.saveProfile(userName, userEmail);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/app');
        return;
      }

      final message = (result['message'] ?? 'Incorrect email or password.').toString();
      setState(() => _errorMessage = message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to connect to backend server at ${ApiService.baseUrl}.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1821),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.biotech_rounded, size: 68, color: Colors.greenAccent),
                      const SizedBox(height: 18),
                      const Text(
                        'DockHub Bio Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email or Username',
                          prefixIcon: const Icon(Icons.email_rounded, color: Colors.greenAccent),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/signup'),
                            child: const Text('Create Account', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showServerConfigDialog,
                        icon: const Icon(Icons.settings_ethernet_rounded, size: 16, color: Colors.white54),
                        label: const Text('Server Connection Settings', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
