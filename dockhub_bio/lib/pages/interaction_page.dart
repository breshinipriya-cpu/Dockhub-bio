import 'package:flutter/material.dart';

import '../models/docking_result.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';

class InteractionPage extends StatelessWidget {
  final DockingResult? result;

  const InteractionPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final contactRows = result?.residueContacts ?? const <Map<String, dynamic>>[];
    final hydrogenBondRows = result?.hydrogenBondCandidates ?? const <Map<String, dynamic>>[];

    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interaction Analysis',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              if (result?.heavyAtomContactCount == null)
                const EmptyStateWidget(
                  icon: Icons.link_rounded,
                  title: 'No Interaction Data',
                  description: 'Run a molecular docking analysis to compute spatial residue contact points and hydrogen bond candidates from the Vina pose.',
                )
              else ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _metric('Atom contacts (≤ 4.0 Å)', '${result!.heavyAtomContactCount}', Icons.adjust_rounded, AppColors.primary),
                    _metric('Residues in contact', '${result!.residueContactCount}', Icons.layers_rounded, AppColors.secondary),
                    _metric('Hydrophobic contacts', '${result!.hydrophobicResidueContactCount}', Icons.bubble_chart_rounded, AppColors.accent),
                    _metric('H-bond candidates (≤ 3.5 Å)', '${result!.hydrogenBondCandidateCount}', Icons.link_rounded, AppColors.info),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Residue Contacts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                if (contactRows.isEmpty)
                  const Text('No residue contacts found under 4.0 Å cutoff.', style: TextStyle(color: AppColors.textSecondary))
                else
                  ...contactRows.map((contact) => _contactCard(
                        residue: '${contact['residue']}',
                        contactsCount: contact['atom_contacts'],
                        minDistance: contact['minimum_distance_angstrom'],
                      )),
                const SizedBox(height: 24),
                const Text('Geometric Donor/Acceptor Candidates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                if (hydrogenBondRows.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Text('No donor/acceptor candidate pairs met the 3.5 Å distance cutoff.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ...hydrogenBondRows.map((candidate) => _hBondCard(
                        residue: '${candidate['residue']}',
                        atoms: '${candidate['ligand_atom']} ↔ ${candidate['protein_atom']}',
                        distance: candidate['distance_angstrom'],
                      )),
                const SizedBox(height: 20),
                if (result?.interactionMethod != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Text(
                      result!.interactionMethod!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 230,
      child: Card(
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactCard({required String residue, required dynamic contactsCount, required dynamic minDistance}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              residue,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$contactsCount atom contacts',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Min distance: $minDistance Å',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hBondCard({required String residue, required String atoms, required dynamic distance}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              residue,
              style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              atoms,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$distance Å',
            style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
