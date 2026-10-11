import 'package:flutter/material.dart';

class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool emailSent = args?['email_sent'] == true;
    final String? resetLink = args?['reset_link']?.toString();
    final String message = args?['message']?.toString() ?? 'Password reset link generated.';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020712), Color(0xFF062F2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: const Color(0xFF0C1821),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mark_email_read_rounded, size: 76, color: Colors.greenAccent),
                    const SizedBox(height: 18),
                    const Text('Check Your Email', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Text(
                      emailSent
                          ? 'A password reset email has been sent to your email inbox! Please click the link inside the email to reset your password.'
                          : message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15),
                    ),
                    if (!emailSent && resetLink != null && resetLink.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06131D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Test Mode Link Preview:',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              resetLink,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                final uri = Uri.parse(resetLink);
                                final token = uri.queryParameters['token'] ?? '';
                                final email = uri.queryParameters['email'] ?? '';
                                Navigator.of(context).pushReplacementNamed(
                                  '/reset-password',
                                  arguments: {'token': token, 'email': email},
                                );
                              },
                              icon: const Icon(Icons.open_in_new_rounded, size: 18),
                              label: const Text('Open Reset Password Page'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
