import 'package:flutter/material.dart';

import '../models/docking_result.dart';

class DockingAnalysisPage extends StatelessWidget {
  final DockingResult? result;

  const DockingAnalysisPage({super.key, required this.result});

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
              const Text('Docking / Binding Analysis', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              Card(
                color: const Color(0xFF0D1F2D),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Docking score: ${result?.dockingScore ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text('Binding affinity / status: ${result?.formattedBindingAffinity ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Text('Interaction status: ${result?.interactionStatus ?? 'Interaction calculation is not currently available.'}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
