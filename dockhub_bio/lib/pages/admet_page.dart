import 'package:flutter/material.dart';

import '../models/docking_result.dart';

class AdmetPage extends StatelessWidget {
  final DockingResult? result;

  const AdmetPage({super.key, required this.result});

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
              const Text('ADMET Analysis', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Text(
                'PubChem physicochemical descriptors for this compound. These are not absorption, distribution, metabolism, excretion, or toxicity predictions.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              _admetTile('Molecular weight', result?.molecularWeight ?? 'Unavailable', 'Da'),
              const SizedBox(height: 12),
              _admetTile('XLogP', result?.xlogp?.toStringAsFixed(2) ?? 'Unavailable', ''),
              const SizedBox(height: 12),
              _admetTile('Topological polar surface area', result?.tpsa?.toStringAsFixed(1) ?? 'Unavailable', 'A^2'),
              const SizedBox(height: 12),
              _admetTile('Hydrogen-bond donors', result?.hydrogenBondDonors?.toString() ?? 'Unavailable', ''),
              const SizedBox(height: 12),
              _admetTile('Hydrogen-bond acceptors', result?.hydrogenBondAcceptors?.toString() ?? 'Unavailable', ''),
              const SizedBox(height: 12),
              _admetTile('Rotatable bonds', result?.rotatableBonds?.toString() ?? 'Unavailable', ''),
              const SizedBox(height: 18),
              const Text('No ADMET or toxicity model was run for this result.', style: TextStyle(color: Colors.amberAccent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _admetTile(String title, String value, String unit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F2D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(unit.isEmpty ? value : '$value $unit', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
