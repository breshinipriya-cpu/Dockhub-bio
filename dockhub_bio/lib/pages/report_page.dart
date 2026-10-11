import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/docking_result.dart';

class ReportPage extends StatelessWidget {
  final DockingResult? result;
  final VoidCallback onSave;

  const ReportPage({super.key, required this.result, required this.onSave});

  pw.Document _createPdf() {
    final report = pw.Document();
    report.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('DockHub Bio Docking Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Protein: ${result?.proteinName ?? 'Not available'}'),
          pw.Text('PDB ID: ${result?.proteinId ?? 'Not available'}'),
          pw.Text('Ligand: ${result?.ligandName ?? 'Not available'}'),
          pw.Text('PubChem CID: ${result?.ligandCid ?? 'Not available'}'),
          pw.Text('Molecular formula: ${result?.molecularFormula ?? 'Not available'}'),
          pw.Text('Molecular weight: ${result?.molecularWeight ?? 'Not available'}'),
          pw.SizedBox(height: 12),
          pw.Text('AutoDock Vina score: ${result?.dockingScore ?? 'Not available'} kcal/mol'),
          pw.Text('Experimental binding affinity: ${result?.formattedBindingAffinity ?? 'Not calculated'}'),
          pw.Text('Docking method: ${result?.dockingMethod ?? 'Not available'}'),
          pw.SizedBox(height: 12),
          pw.Text(result?.dockingBoxMethod ?? 'Docking box method not available.'),
          pw.SizedBox(height: 8),
          pw.Text(result?.analysisNotice ?? 'Additional analysis was not performed.'),
        ],
      ),
    );
    return report;
  }

  Future<void> _printReport() async {
    final report = _createPdf();
    await Printing.layoutPdf(onLayout: (_) => report.save());
  }

  Future<void> _exportPdf() async {
    final report = _createPdf();
    await Printing.sharePdf(
      bytes: await report.save(),
      filename: 'dockhub_docking_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: const Color(0xFF0D1F2D),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complete Report', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  Text('Protein: ${result?.proteinName ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('PDB ID: ${result?.proteinId ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Ligand: ${result?.ligandName ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('PubChem CID: ${result?.ligandCid ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Molecular formula: ${result?.molecularFormula ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Molecular weight: ${result?.molecularWeight ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('SMILES: ${result?.canonicalSmiles ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('AutoDock Vina score: ${result?.dockingScore ?? 'N/A'} kcal/mol', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Experimental binding affinity: ${result?.formattedBindingAffinity ?? 'Not calculated'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Docking method: ${result?.dockingMethod ?? 'AutoDock Vina'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Text(result?.dockingBoxMethod ?? 'Docking box method not available.', style: const TextStyle(color: Colors.amberAccent)),
                  const SizedBox(height: 8),
                  Text(result?.analysisNotice ?? 'Additional analysis was not performed.', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(onPressed: result == null ? null : onSave, icon: const Icon(Icons.save_rounded), label: const Text('Save')),
                      ElevatedButton.icon(onPressed: result == null ? null : _printReport, icon: const Icon(Icons.print_rounded), label: const Text('Print')),
                      ElevatedButton.icon(onPressed: result == null ? null : _exportPdf, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Export PDF')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
