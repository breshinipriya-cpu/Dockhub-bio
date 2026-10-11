import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pages/forgot_password_page.dart';
import 'pages/login_page.dart';
import 'pages/password_reset_success_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/signup_page.dart';
import 'pages/splash_page.dart';
import 'pages/welcome_page.dart';
import 'theme/app_theme.dart';

class DockHubBioApp extends StatefulWidget {
  const DockHubBioApp({super.key});

  @override
  State<DockHubBioApp> createState() => _DockHubBioAppState();
}

class _DockHubBioAppState extends State<DockHubBioApp> {
  final ValueNotifier<String> _language = ValueNotifier<String>('en');
  final ValueNotifier<bool> _animations = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _language.dispose();
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DockHub Bio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/password-reset-success': (context) => const PasswordResetSuccessPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/app': (context) => const AppShell(),
      },
    );
  }
}

class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScaleRoute(this.page)
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutCirc))
                .animate(animation);
            final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutCubic))
                .animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}
