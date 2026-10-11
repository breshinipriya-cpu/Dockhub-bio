import 'package:flutter/material.dart';

import '../models/docking_result.dart';
import '../widgets/structure_3d_viewer.dart';

class ProteinDetailsPage extends StatelessWidget {
  final DockingResult? result;

  const ProteinDetailsPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final pdbId = result?.proteinId;
    final resText = result?.resolution ?? 'N/A';

    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Protein Details', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              Card(
                color: const Color(0xFF0D1F2D),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Protein name: ${result?.proteinName ?? 'Protein not available'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('PDB ID: ${pdbId ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Organism: ${result?.proteinOrganism ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Experimental method: ${result?.experimentalMethod ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Resolution: $resText', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Structure3DViewer(
                pdbId: pdbId,
                proteinName: result?.proteinName,
                height: 480,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
