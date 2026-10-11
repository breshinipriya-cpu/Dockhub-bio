import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  final String userName;
  final List<HistoryItem> history;
  final int savedCount;
  final int proteinSearchCount;
  final int ligandSearchCount;
  final VoidCallback onQuickDock;
  final VoidCallback onProteinSearch;
  final VoidCallback onLigandSearch;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.history,
    required this.savedCount,
    required this.proteinSearchCount,
    required this.ligandSearchCount,
    required this.onQuickDock,
    required this.onProteinSearch,
    required this.onLigandSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final welcome = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome , $userName', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      const Text('Research dashboard', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  );
                  final newDockingButton = ElevatedButton.icon(
                    onPressed: onQuickDock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    icon: const Icon(Icons.add_circle_rounded),
                    label: const Text('New Docking'),
                  );

                  if (constraints.maxWidth < 850) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [welcome, const SizedBox(height: 14), newDockingButton],
                    );
                  }

                  return Row(
                    children: [Expanded(child: welcome), const SizedBox(width: 16), newDockingButton],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000
                      ? 4
                      : constraints.maxWidth >= 600
                          ? 2
                          : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 4 ? 1.9 : 2.5,
                    children: [
                      StatCard(title: 'Total Docking Studies', value: '${history.length}', icon: Icons.analytics_rounded, color: Colors.greenAccent),
                      StatCard(title: 'Proteins Searched', value: '$proteinSearchCount', icon: Icons.biotech_rounded, color: Colors.cyanAccent),
                      StatCard(title: 'Ligands Analyzed', value: '$ligandSearchCount', icon: Icons.science_rounded, color: Colors.tealAccent),
                      StatCard(title: 'Saved Results', value: '$savedCount', icon: Icons.bookmark_rounded, color: Colors.orangeAccent),
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) {
                  final proteinTile = _QuickActionTile(
                    icon: Icons.bolt_rounded,
                    label: 'Quick Search Protein',
                    onTap: onProteinSearch,
                  );
                  final ligandTile = _QuickActionTile(
                    icon: Icons.science_rounded,
                    label: 'Quick Search Ligand',
                    onTap: onLigandSearch,
                  );
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [proteinTile, const SizedBox(height: 12), ligandTile],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: proteinTile),
                      const SizedBox(width: 16),
                      Expanded(child: ligandTile),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text('Recent Docking Studies', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (history.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1F2D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Text('No recent docking studies yet. Start a new docking run to populate the dashboard.', style: TextStyle(color: Colors.white70)),
                )
              else
                Column(
                  children: history.take(4).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1F2D),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.protein} / ${item.ligand}', style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('PDB: ${item.pdbId}', style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(item.dockingScore, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F2D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.greenAccent),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
