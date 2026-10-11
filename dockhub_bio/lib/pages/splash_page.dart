import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _controller.repeat(reverse: true);
    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020712), Color(0xFF062B27), Color(0xFF020712)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 0.85 + (_controller.value * 0.2);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 2),
                  ),
                  child: const Icon(Icons.biotech_rounded, size: 72, color: Colors.greenAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DockHub Bio',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.greenAccent),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Molecular docking workspace',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: Colors.greenAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
