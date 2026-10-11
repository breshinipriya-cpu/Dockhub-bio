import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LigandSearchPage extends StatefulWidget {
  final Future<void> Function(String query) onSearchSuccess;

  const LigandSearchPage({super.key, required this.onSearchSuccess});

  @override
  State<LigandSearchPage> createState() => _LigandSearchPageState();
}

class _LigandSearchPageState extends State<LigandSearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _result = {'success': false, 'message': 'Ligand name is required.'});
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await ApiService.searchLigand(query);
      if (!mounted) return;
      setState(() => _result = data);
      if (data['success'] == true) await widget.onSearchSuccess(query);
    } catch (_) {
      if (!mounted) return;
      setState(() => _result = {'success': false, 'message': 'Ligand not found. Please check the ligand name.'});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
              const Text('Ligand Search', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Ligand name',
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.greenAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _search,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                    child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (_result == null)
                const Text('Search by compound or name to fetch PubChem metadata.', style: TextStyle(color: Colors.white70))
              else if (_result!['success'] == false)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF0D1F2D), borderRadius: BorderRadius.circular(18)),
                  child: Text(_result!['message'] ?? 'Ligand not found. Please check the ligand name.', style: const TextStyle(color: Colors.white70)),
                )
              else
                Card(
                  color: const Color(0xFF0D1F2D),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compound name: ${_result!['compound_name'] ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('CID: ${_result!['cid'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('Molecular formula: ${_result!['molecular_formula'] ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('Molecular weight: ${_result!['molecular_weight'] ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('Canonical SMILES: ${_result!['canonical_smiles'] ?? 'Analysis not currently available'}', style: const TextStyle(color: Colors.white70)),
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
