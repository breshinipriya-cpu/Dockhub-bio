import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'structure_3d_viewer_impl.dart';

class Structure3DViewer extends StatefulWidget {
  final String? pdbId;
  final String? proteinName;
  final double height;

  const Structure3DViewer({
    super.key,
    required this.pdbId,
    this.proteinName,
    this.height = 480,
  });

  @override
  State<Structure3DViewer> createState() => _Structure3DViewerState();
}

class _Structure3DViewerState extends State<Structure3DViewer> {
  late String _viewId;
  bool _iframeRegistered = false;

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  @override
  void didUpdateWidget(covariant Structure3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdbId != widget.pdbId) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    final pdb = widget.pdbId?.trim().toUpperCase();
    if (pdb == null || pdb.isEmpty || pdb == 'N/A' || pdb == 'PDB ID NOT AVAILABLE') {
      return;
    }
    _viewId = 'pdb-3d-viewer-$pdb-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      final iframeUrl = 'https://3dmol.org/viewer.html?pdb=$pdb&style=cartoon:color~spectrum';
      registerIframeView(_viewId, iframeUrl);
      if (mounted) {
        setState(() => _iframeRegistered = true);
      }
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final pdb = widget.pdbId?.trim().toUpperCase();
    final isValidPdb = pdb != null &&
        pdb.isNotEmpty &&
        pdb != 'N/A' &&
        pdb != 'PDB ID NOT AVAILABLE' &&
        RegExp(r'^[A-Za-z0-9]{4}$').hasMatch(pdb);

    if (!isValidPdb) {
      return Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0D1F2D),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.biotech_rounded, size: 40, color: Colors.white38),
              SizedBox(height: 12),
              Text(
                'No valid PDB ID loaded for 3D structure visualization.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF07131D),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF0D1F2D),
            child: Row(
              children: [
                const Icon(Icons.threed_rotation_rounded, color: Colors.greenAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Interactive 3D Structure Viewer - PDB: $pdb',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openExternal('https://www.rcsb.org/3d-view/$pdb'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.greenAccent),
                  label: const Text('RCSB 3D', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: widget.height,
            child: kIsWeb && _iframeRegistered
                ? HtmlElementView(viewType: _viewId)
                : Container(
                    color: const Color(0xFF040E17),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.view_in_ar_rounded, size: 50, color: Colors.greenAccent),
                          const SizedBox(height: 14),
                          Text('Structure PDB ID: $pdb', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openExternal('https://www.rcsb.org/3d-view/$pdb'),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open Interactive 3D Viewer'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
