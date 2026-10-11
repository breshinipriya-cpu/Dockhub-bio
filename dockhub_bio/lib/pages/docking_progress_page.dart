import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DockingProgressPage extends StatefulWidget {
  final String protein;
  final String ligand;
  final String userEmail;

  const DockingProgressPage({
    super.key,
    required this.protein,
    required this.ligand,
    required this.userEmail,
  });

  @override
  State<DockingProgressPage> createState() => _DockingProgressPageState();
}

class _DockingProgressPageState extends State<DockingProgressPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Future<Map<String, dynamic>> _analysisFuture;
  late Timer _stepTimer;
  int _currentStepIndex = 0;

  final List<String> _stages = [
    'Resolving protein structure in RCSB PDB',
    'Resolving ligand compound in PubChem',
    'Downloading source coordinates & PDB files',
    'Preparing receptor and ligand PDBQT formats',
    'Executing AutoDock Vina molecular docking simulation',
    'Analyzing residue contact points and storing pose',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    
    // Animate stage progression over time
    _stepTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _currentStepIndex < _stages.length - 1) {
        setState(() => _currentStepIndex++);
      }
    });

    _analysisFuture = ApiService.analyze(
      protein: widget.protein,
      ligand: widget.ligand,
      userEmail: widget.userEmail,
    );
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              color: AppColors.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _analysisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.biotech_rounded, size: 48, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Molecular Docking In Progress',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Docking target: ${widget.protein} • Ligand: ${widget.ligand}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 28),
                          const LinearProgressIndicator(
                            backgroundColor: AppColors.surfaceDark,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 28),
                          Column(
                            children: List.generate(_stages.length, (index) {
                              final isCompleted = index < _currentStepIndex;
                              final isCurrent = index == _currentStepIndex;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? AppColors.primary
                                            : isCurrent
                                                ? AppColors.primary.withValues(alpha: 0.25)
                                                : AppColors.surfaceDark,
                                        border: Border.all(
                                          color: isCurrent || isCompleted
                                              ? AppColors.primary
                                              : AppColors.cardBorderDark,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(Icons.check, size: 14, color: Colors.black)
                                          : isCurrent
                                              ? Center(
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        _stages[index],
                                        style: TextStyle(
                                          color: isCurrent
                                              ? AppColors.textPrimary
                                              : isCompleted
                                                  ? AppColors.primary.withValues(alpha: 0.9)
                                                  : AppColors.textMuted,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop({'success': false, 'message': 'Unable to retrieve analysis data. Please check backend connection.'});
                      });
                      return const SizedBox();
                    }

                    final data = snapshot.data!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pop(data);
                    });
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
