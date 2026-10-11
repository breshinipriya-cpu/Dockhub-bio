import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/docking_result.dart';
import '../theme/app_theme.dart';

class LigandDetailsPage extends StatefulWidget {
  final DockingResult? result;

  const LigandDetailsPage({super.key, required this.result});

  @override
  State<LigandDetailsPage> createState() => _LigandDetailsPageState();
}

class _LigandDetailsPageState extends State<LigandDetailsPage> {
  int _selectedStructureTab = 0; // 0: 2D Diagram, 1: 3D Conformer, 2: Interactive 3D

  bool _hasValue(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value != 'Analysis not currently available' &&
        value != 'N/A';
  }

  String? get _cid {
    final cidStr = widget.result?.ligandCid;
    if (_hasValue(cidStr)) {
      return cidStr!.trim();
    }
    return null;
  }

  String? get _ligandName {
    final name = widget.result?.ligandName;
    if (_hasValue(name)) {
      return name!.trim();
    }
    return null;
  }

  String _get2dImageUrl() {
    final cid = _cid;
    if (cid != null && RegExp(r'^\d+$').hasMatch(cid)) {
      return 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG?record_type=2d&image_size=large';
    }
    final name = _ligandName;
    if (name != null) {
      return 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/${Uri.encodeComponent(name)}/PNG?record_type=2d&image_size=large';
    }
    return '';
  }

  String _get3dImageUrl() {
    final cid = _cid;
    if (cid != null && RegExp(r'^\d+$').hasMatch(cid)) {
      return 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG?record_type=3d&image_size=large';
    }
    final name = _ligandName;
    if (name != null) {
      return 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/${Uri.encodeComponent(name)}/PNG?record_type=3d&image_size=large';
    }
    return '';
  }

  Future<void> _openPubChemSection(String section) async {
    final cid = _cid;
    Uri uri;
    if (cid != null && RegExp(r'^\d+$').hasMatch(cid)) {
      uri = Uri.parse('https://pubchem.ncbi.nlm.nih.gov/compound/$cid#section=$section');
    } else if (_ligandName != null) {
      uri = Uri.parse('https://pubchem.ncbi.nlm.nih.gov/#query=${Uri.encodeComponent(_ligandName!)}');
    } else {
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link.')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final smiles = result?.canonicalSmiles;
    final hasSmiles = _hasValue(smiles);
    final imageUrl2d = _get2dImageUrl();
    final imageUrl3d = _get3dImageUrl();
    final hasImage = imageUrl2d.isNotEmpty;

    return Container(
      color: const Color(0xFF030914),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ligand Details & Structure',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View chemical compound properties, canonical SMILES, 2D molecular diagram, and 3D conformer structure options.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Compound Info Card
              Card(
                color: const Color(0xFF071322),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: const Color(0xFF00F2FE).withValues(alpha: 0.25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F2FE).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.science_rounded, color: Color(0xFF00F2FE), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result?.ligandName ?? 'Ligand not available',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_cid != null)
                                  Text(
                                    'PubChem CID: $_cid',
                                    style: const TextStyle(
                                      color: Color(0xFF00F2FE),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      _buildDetailRow('Molecular Formula', result?.molecularFormula ?? 'N/A', Icons.functions_rounded),
                      const SizedBox(height: 10),
                      _buildDetailRow('Molecular Weight', result?.molecularWeight ?? 'N/A', Icons.scale_rounded),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.code_rounded, size: 18, color: Color(0xFF2DD4BF)),
                          const SizedBox(width: 10),
                          const Text(
                            'Canonical SMILES: ',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: SelectableText(
                              smiles ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (hasSmiles)
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF00F2FE)),
                              tooltip: 'Copy SMILES',
                              onPressed: () => _copyToClipboard(smiles!, 'Canonical SMILES'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // STRUCTURE OPTIONS SECTION
              Card(
                color: const Color(0xFF071322),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.view_in_ar_rounded, color: Color(0xFF2DD4BF), size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Molecular Structure Options',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (_cid != null)
                            OutlinedButton.icon(
                              onPressed: () => _openPubChemSection('2D-Structure'),
                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                              label: const Text('PubChem Page'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00F2FE),
                                side: const BorderSide(color: Color(0xFF00F2FE)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Toggle Tabs for Structure Option (2D Diagram vs 3D Conformer vs Interactive View)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF030914),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildTabButton(0, '2D Structure Diagram', Icons.crop_original_rounded),
                            _buildTabButton(1, '3D Conformer View', Icons.threed_rotation_rounded),
                            _buildTabButton(2, 'Interactive PubChem 3D', Icons.open_in_browser_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Structure Tab Content
                      if (_selectedStructureTab == 0) ...[
                        _build2dStructureView(imageUrl2d, hasImage),
                      ] else if (_selectedStructureTab == 1) ...[
                        _build3dStructureView(imageUrl3d, hasImage),
                      ] else ...[
                        _buildInteractive3dView(),
                      ],
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2DD4BF)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedStructureTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStructureTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00F2FE).withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.6))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF00F2FE) : Colors.white60,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build2dStructureView(String imageUrl, bool hasImage) {
    if (!hasImage) {
      return _buildNoStructureFallback('No valid ligand CID or name available for 2D diagram generation.');
    }
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF040E18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF00F2FE)),
                SizedBox(height: 12),
                Text('Fetching 2D Structure Diagram from PubChem...', style: TextStyle(color: Colors.white70)),
              ],
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildNoStructureFallback('Unable to load 2D structure image from PubChem.');
          },
        ),
      ),
    );
  }

  Widget _build3dStructureView(String imageUrl, bool hasImage) {
    if (!hasImage) {
      return _buildNoStructureFallback('No valid ligand CID or name available for 3D conformer rendering.');
    }
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF040E18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                SizedBox(height: 12),
                Text('Loading 3D Conformer Render from PubChem...', style: TextStyle(color: Colors.white70)),
              ],
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildNoStructureFallback('Unable to load 3D conformer image from PubChem.');
          },
        ),
      ),
    );
  }

  Widget _buildInteractive3dView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF040E18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.threed_rotation_rounded, size: 56, color: Color(0xFF00F2FE)),
          const SizedBox(height: 16),
          Text(
            _ligandName != null ? 'Interactive 3D Structure: $_ligandName' : 'Interactive 3D Structure Viewer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore the 3D conformer, atom coordinates, electron density, and chemical bonds directly on PubChem or RCSB.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openPubChemSection('3D-Conformer'),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open PubChem 3D Conformer Viewer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: const Color(0xFF020914),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openPubChemSection('2D-Structure'),
                icon: const Icon(Icons.science_rounded),
                label: const Text('View Chemical Properties'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2DD4BF)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoStructureFallback(String message) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF040E18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported_rounded, size: 42, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

