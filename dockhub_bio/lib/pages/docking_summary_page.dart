import 'package:flutter/material.dart';

import '../models/docking_result.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class DockingSummaryPage extends StatelessWidget {
  final DockingResult result;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSave;

  const DockingSummaryPage({
    super.key,
    required this.result,
    required this.onNavigate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Docking Summary', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              Card(
                color: AppColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: AppColors.cardBorderDark),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Protein: ${result.proteinName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text('PDB ID: ${result.proteinId}', style: const TextStyle(color: AppColors.textSecondary)),
                      if (result.proteinOrganism != null) ...[
                        const SizedBox(height: 6),
                        Text('Organism: ${result.proteinOrganism}', style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                      if (result.experimentalMethod != null) ...[
                        const SizedBox(height: 6),
                        Text('Method: ${result.experimentalMethod}', style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                      if (result.resolution != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Resolution: ${result.resolution!.contains('Å') ? result.resolution : '${result.resolution} Å'}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text('Ligand: ${result.ligandName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text('Docking Score: ${result.formattedDockingScore} (AutoDock Vina estimated binding energy)', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, cardConstraints) {
                          final vinaCard = StatCard(
                            title: 'Docking Score (Vina)',
                            value: result.formattedDockingScore,
                            icon: Icons.bolt_rounded,
                            color: AppColors.primary,
                          );
                          final affinityCard = StatCard(
                            title: 'Experimental Affinity',
                            value: result.formattedBindingAffinity,
                            icon: Icons.link_rounded,
                            color: AppColors.secondary,
                          );

                          if (cardConstraints.maxWidth < 500) {
                            return Column(
                              children: [
                                vinaCard,
                                const SizedBox(height: 12),
                                affinityCard,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: vinaCard),
                              const SizedBox(width: 12),
                              Expanded(child: affinityCard),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (result.dockingBoxMethod != null || result.analysisNotice != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    [result.dockingBoxMethod, result.analysisNotice]
                        .whereType<String>()
                        .where((value) => value != 'Analysis not currently available')
                        .join('\n'),
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionButton(label: 'View Protein', icon: Icons.biotech_rounded, onTap: () => onNavigate(7)),
                  _ActionButton(label: 'View Ligand', icon: Icons.science_rounded, onTap: () => onNavigate(8)),
                  _ActionButton(label: 'View Interactions', icon: Icons.link_rounded, onTap: () => onNavigate(9)),
                  _ActionButton(label: 'View ADMET', icon: Icons.health_and_safety_rounded, onTap: () => onNavigate(10)),
                  _ActionButton(label: 'View Ramachandran', icon: Icons.insights_rounded, onTap: () => onNavigate(12)),
                  _ActionButton(label: 'View Complete Report', icon: Icons.description_rounded, onTap: () => onNavigate(18)),
                  _ActionButton(label: 'Save Result', icon: Icons.bookmark_rounded, onTap: onSave),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        side: const BorderSide(color: AppColors.cardBorderDark),
      ),
    );
  }
}
