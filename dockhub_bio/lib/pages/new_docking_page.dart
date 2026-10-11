import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/docking_result.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dna_helix_painter.dart';
import 'docking_progress_page.dart';

class NewDockingPage extends StatefulWidget {
  final String userEmail;
  final Future<void> Function(DockingResult result) onAnalyze;

  const NewDockingPage({
    super.key,
    required this.userEmail,
    required this.onAnalyze,
  });

  @override
  State<NewDockingPage> createState() => _NewDockingPageState();
}

class _NewDockingPageState extends State<NewDockingPage> {
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _ligandController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ApiService.pingServer();
  }

  @override
  void dispose() {
    _proteinController.dispose();
    _ligandController.dispose();
    super.dispose();
  }

  void _clear() {
    _proteinController.clear();
    _ligandController.clear();
    setState(() => _errorMessage = null);
  }

  Future<void> _startDocking() async {
    final protein = _proteinController.text.trim();
    final ligand = _ligandController.text.trim();

    if (protein.isEmpty) {
      setState(() => _errorMessage = 'Protein name or PDB ID is required.');
      return;
    }
    if (ligand.isEmpty) {
      setState(() => _errorMessage = 'Ligand name or PubChem compound is required.');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DockingProgressPage(
            protein: protein,
            ligand: ligand,
            userEmail: widget.userEmail,
          ),
        ),
      );

      if (!mounted) return;
      if (result is Map<String, dynamic>) {
        final data = result;
        if (data['success'] == false) {
          setState(() => _errorMessage = (data['message'] ?? 'Unable to retrieve analysis data. Please try again.').toString());
          return;
        }
        final dockingResult = DockingResult.fromJson(data);
        await widget.onAnalyze(dockingResult);
      }
    } catch (_) {
      setState(() => _errorMessage = 'Unable to retrieve analysis data. Please check connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 800;

    return Container(
      color: const Color(0xFF030914),
      child: Stack(
        children: [
          // 1. Deep Midnight Biotech Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020914),
                    Color(0xFF071728),
                    Color(0xFF030D1B),
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
                    const Color(0xFF00F2FE).withValues(alpha: 0.16),
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
                    const Color(0xFF2DD4BF).withValues(alpha: 0.14),
                    const Color(0xFF2DD4BF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. FULL SCREEN BACKGROUND: Light-colored Glowing 3D Rotating DNA Helix (Same as Welcome Page)
          Positioned.fill(
            child: Center(
              child: DnaHelixWidget(
                width: isCompact ? size.width * 0.9 : 520,
                height: size.height,
                isLightTheme: false,
                radiusFraction: isCompact ? 0.40 : 0.35,
                opacityMultiplier: 0.85,
              ),
            ),
          ),

          // 4. FOREGROUND CONTENT: Docking Form Elements
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Docking Analysis',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Run an AutoDock Vina molecular docking analysis using protein target PDB IDs and ligand PubChem compound names.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF071322).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(22),
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
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ApiService.isLocal
                                          ? Colors.greenAccent.withValues(alpha: 0.4)
                                          : const Color(0xFF00F2FE).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        ApiService.isLocal ? Icons.offline_bolt_rounded : Icons.cloud_done_rounded,
                                        size: 18,
                                        color: ApiService.isLocal ? Colors.greenAccent : const Color(0xFF00F2FE),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          ApiService.isLocal
                                              ? 'Backend: Local Engine (127.0.0.1:8000 • Instant)'
                                              : 'Backend: Cloud Server (Render)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: ApiService.isLocal ? Colors.greenAccent : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            if (ApiService.isLocal) {
                                              ApiService.useCloudBackend();
                                            } else {
                                              ApiService.useLocalBackend();
                                            }
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        child: Text(
                                          ApiService.isLocal ? 'Use Cloud' : 'Use Local',
                                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextField(
                                  controller: _proteinController,
                                  decoration: InputDecoration(
                                    labelText: 'Protein Target / PDB ID (e.g., 1HSG or HIV-1 Protease)',
                                    prefixIcon: const Icon(Icons.biotech_rounded, color: AppColors.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextField(
                                  controller: _ligandController,
                                  decoration: InputDecoration(
                                    labelText: 'Ligand Compound / CID (e.g., Aspirin or 2244)',
                                    prefixIcon: const Icon(Icons.science_rounded, color: AppColors.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (_errorMessage != null)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            if (!ApiService.isLocal)
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    ApiService.useLocalBackend();
                                                    _errorMessage = null;
                                                  });
                                                  _startDocking();
                                                },
                                                icon: const Icon(Icons.offline_bolt_rounded, size: 16),
                                                label: const Text('Switch to Local Engine & Retry', style: TextStyle(fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.greenAccent.shade700,
                                                  foregroundColor: Colors.white,
                                                  visualDensity: VisualDensity.compact,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                ),
                                              ),
                                            OutlinedButton.icon(
                                              onPressed: _startDocking,
                                              icon: const Icon(Icons.refresh_rounded, size: 16),
                                              label: const Text('Retry', style: TextStyle(fontSize: 12)),
                                              style: OutlinedButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                                foregroundColor: AppColors.textPrimary,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                LayoutBuilder(
                                  builder: (context, buttonConstraints) {
                                    final startButton = ElevatedButton.icon(
                                      onPressed: _loading ? null : _startDocking,
                                      icon: const Icon(Icons.bolt_rounded),
                                      label: const Text('Start Docking Simulation'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      ),
                                    );
                                    final clearButton = OutlinedButton.icon(
                                      onPressed: _clear,
                                      icon: const Icon(Icons.clear_rounded),
                                      label: const Text('Clear Inputs'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                        side: const BorderSide(color: AppColors.cardBorderDark),
                                      ),
                                    );

                                    if (buttonConstraints.maxWidth < 450) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          startButton,
                                          const SizedBox(height: 12),
                                          clearButton,
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(child: startButton),
                                        const SizedBox(width: 12),
                                        Expanded(child: clearButton),
                                      ],
                                    );
                                  },
                                ),
                              ],
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
        ],
      ),
    );
  }
}

