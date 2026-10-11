import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/docking_result.dart';
import '../services/api_service.dart';
import '../widgets/structure_3d_viewer.dart';

class MolecularStructurePage extends StatelessWidget {
  final DockingResult? result;

  const MolecularStructurePage({super.key, required this.result});

  bool _hasValue(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value != 'Analysis not currently available' &&
        value != 'PDB ID not available' &&
        value != 'N/A';
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this structure link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdbId = result?.proteinId;

    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFF0D1F2D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Molecular Structure Viewer', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      const Text('Open the experimentally deposited protein structure, PubChem ligand conformer, or download the pose produced by AutoDock Vina.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _hasValue(result?.proteinId)
                                ? () => _openLink(context, Uri.parse('https://www.rcsb.org/3d-view/${result!.proteinId}'))
                                : null,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open Protein in RCSB'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _hasValue(result?.ligandCid)
                                ? () => _openLink(context, Uri.parse('https://pubchem.ncbi.nlm.nih.gov/compound/${result!.ligandCid}#section=3D-Conformer'))
                                : null,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open Ligand in PubChem'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _hasValue(result?.proteinId) && _hasValue(result?.ligandCid)
                                ? () => _openLink(
                                      context,
                                      Uri.parse('${ApiService.baseUrl}/docked_pose/${result!.proteinId}/${result!.ligandCid}'),
                                    )
                                : null,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download Docked Pose'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Structure3DViewer(
                pdbId: pdbId,
                proteinName: result?.proteinName,
                height: 520,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
