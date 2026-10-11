import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/dna_helix_painter.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 800;

    final features = [
      {'label': 'Molecular Docking', 'icon': Icons.tune_rounded},
      {'label': 'Protein Analysis', 'icon': Icons.biotech_rounded},
      {'label': 'Ligand Screening', 'icon': Icons.science_rounded},
      {'label': 'ADMET Review', 'icon': Icons.health_and_safety_rounded},
      {'label': '3D Structure Viewer', 'icon': Icons.view_in_ar_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF030914),
      body: Stack(
        children: [
          // 1. Deep Midnight Biotech Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020914), // Deep Midnight
                    Color(0xFF071728), // Deep Teal Navy
                    Color(0xFF030D1B), // Dark Biotech
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Ambient Background Glow Spheres
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00F2FE).withValues(alpha: 0.18),
                    const Color(0xFF00F2FE).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2DD4BF).withValues(alpha: 0.16),
                    const Color(0xFF2DD4BF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. FULL SCREEN BACKGROUND: Light-colored Glowing 3D Rotating DNA Helix
          Positioned.fill(
            child: Center(
              child: DnaHelixWidget(
                width: isCompact ? size.width * 0.9 : 520,
                height: size.height,
                isLightTheme: false, // Glowing neon light colors on dark background
                radiusFraction: isCompact ? 0.40 : 0.35,
                opacityMultiplier: 0.85,
              ),
            ),
          ),

          // 4. FOREGROUND CONTENT: Text & UI Elements DIRECTLY ON TOP of Rotating DNA
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: EdgeInsets.all(isCompact ? 24 : 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF071322).withValues(alpha: 0.70), // Glassmorphic dark card
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFF00F2FE).withValues(alpha: 0.30),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.40),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: const Color(0xFF00F2FE).withValues(alpha: 0.10),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge Tag Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F2FE).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFF00F2FE).withValues(alpha: 0.40),
                                ),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.biotech_rounded, size: 18, color: Color(0xFF00F2FE)),
                                    SizedBox(width: 8),
                                    Text(
                                      'DOCKHUB BIO PLATFORM',
                                      style: TextStyle(
                                        color: Color(0xFF00F2FE),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Headline Text
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: isCompact ? 32 : 42,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Roboto',
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                                children: const [
                                  TextSpan(text: 'Welcome to '),
                                  TextSpan(
                                    text: 'DockHub Bio',
                                    style: TextStyle(
                                      color: Color(0xFF00F2FE),
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFF00F2FE),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtitle Description
                            Text(
                              'A professional platform for molecular docking, protein & ligand analysis, ADMET profiling, and interactive 3D result tracking.',
                              style: TextStyle(
                                color: const Color(0xD8FFFFFF),
                                fontSize: isCompact ? 15 : 18,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Feature Chips
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: features.map((item) {
                                final label = item['label'] as String;
                                final icon = item['icon'] as IconData;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F2338).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(icon, size: 16, color: const Color(0xFF2DD4BF)),
                                        const SizedBox(width: 6),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: isCompact ? 13 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 28),

                            // Action Button
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                              label: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00F2FE),
                                foregroundColor: const Color(0xFF020914),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                elevation: 6,
                                shadowColor: const Color(0xFF00F2FE).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Footer highlight strip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF040C18).withValues(alpha: 0.70),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(child: _buildStatItem('AutoDock Vina', 'Integrated Engine')),
                                  Container(width: 1, height: 28, color: Colors.white24),
                                  Expanded(child: _buildStatItem('RCSB & PubChem', 'Real-Time Sync')),
                                  Container(width: 1, height: 28, color: Colors.white24),
                                  Expanded(child: _buildStatItem('ADMET & 3D', 'Instant Analysis')),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF00F2FE),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
