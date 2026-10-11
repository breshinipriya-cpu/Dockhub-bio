import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';

class HistoryPage extends StatelessWidget {
  final List<HistoryItem> history;
  final void Function(HistoryItem item) onOpen;

  const HistoryPage({super.key, required this.history, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Protein & Docking History',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 18),
              if (history.isEmpty)
                const Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: 'No History Recorded',
                    description: 'Executed molecular docking runs and protein analysis sessions will automatically be stored here.',
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final displayScore = (item.dockingScore != 'N/A' && !item.dockingScore.contains('kcal/mol'))
                          ? '${item.dockingScore} kcal/mol'
                          : item.dockingScore;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppColors.cardDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.cardBorderDark),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.history_rounded, color: AppColors.primary),
                          ),
                          title: Text(
                            '${item.protein} vs ${item.ligand}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            'PDB: ${item.pdbId} • ${item.dateTime.toLocal().toString().split('.').first}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              displayScore,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          onTap: () => onOpen(item),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
