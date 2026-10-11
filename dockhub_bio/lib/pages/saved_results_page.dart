import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';

class SavedResultsPage extends StatelessWidget {
  final List<SavedResult> saved;
  final void Function(SavedResult item) onOpen;

  const SavedResultsPage({super.key, required this.saved, required this.onOpen});

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
                'Saved Results',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 18),
              if (saved.isEmpty)
                const Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.bookmark_rounded,
                    title: 'No Saved Results',
                    description: 'Bookmark and save important docking score calculations from the summary page to view them here.',
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: saved.length,
                    itemBuilder: (context, index) {
                      final item = saved[index];
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
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bookmark_rounded, color: AppColors.secondary),
                          ),
                          title: Text(
                            '${item.protein} vs ${item.ligand}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            'PDB: ${item.pdbId} • Saved: ${item.dateTime.toLocal().toString().split('.').first}',
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
