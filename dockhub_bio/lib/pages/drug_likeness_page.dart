import 'package:flutter/material.dart';

import '../models/docking_result.dart';

class DrugLikenessPage extends StatelessWidget {
  final DockingResult? result;

  const DrugLikenessPage({super.key, required this.result});

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
              const Text('Drug-Likeness', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Text('PubChem descriptors screened against Lipinski Rule of Five. This is a physicochemical filter, not a drug approval or efficacy prediction.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              Card(
                color: const Color(0xFF0D1F2D),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result?.lipinskiStatus ?? 'Rule-of-Five screen unavailable: required PubChem descriptors are missing.',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (result == null || result!.lipinskiViolations.isEmpty)
                        const Text('No violations reported.', style: TextStyle(color: Colors.white70))
                      else
                        ...result!.lipinskiViolations.map((violation) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(violation, style: const TextStyle(color: Colors.amberAccent)),
                            )),
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
