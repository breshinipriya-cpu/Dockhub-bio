import 'dart:math' as math;

class DockingResult {
  final String proteinName;
  final String ligandName;
  final String proteinId;
  final String? molecularFormula;
  final String? molecularWeight;
  final String? canonicalSmiles;
  final String dockingScore;
  final String? bindingAffinity;
  final String interactionStatus;
  final String? absorption;
  final String? distribution;
  final String? metabolism;
  final String? excretion;
  final String? toxicity;
  final String? drugLikeness;
  final String? proteinOrganism;
  final String? experimentalMethod;
  final String? resolution;
  final String? ramachandranFavored;
  final String? ramachandranAllowed;
  final String? ramachandranOutlier;
  final String? ligandCid;
  final String? compoundName;
  final String? message;
  final String? dockingMethod;
  final String? dockingBoxMethod;
  final String? analysisNotice;
  final double? xlogp;
  final double? tpsa;
  final int? hydrogenBondDonors;
  final int? hydrogenBondAcceptors;
  final int? rotatableBonds;
  final String? lipinskiStatus;
  final List<String> lipinskiViolations;
  final int? heavyAtomContactCount;
  final int? residueContactCount;
  final int? hydrophobicResidueContactCount;
  final int? hydrogenBondCandidateCount;
  final List<Map<String, dynamic>> residueContacts;
  final List<Map<String, dynamic>> hydrogenBondCandidates;
  final String? interactionMethod;
  final List<RamachandranPoint> ramachandranPoints;
  final String? ramachandranMessage;

  const DockingResult({
    required this.proteinName,
    required this.ligandName,
    required this.proteinId,
    this.molecularFormula,
    this.molecularWeight,
    this.canonicalSmiles,
    required this.dockingScore,
    this.bindingAffinity,
    required this.interactionStatus,
    this.absorption,
    this.distribution,
    this.metabolism,
    this.excretion,
    this.toxicity,
    this.drugLikeness,
    this.proteinOrganism,
    this.experimentalMethod,
    this.resolution,
    this.ramachandranFavored,
    this.ramachandranAllowed,
    this.ramachandranOutlier,
    this.ligandCid,
    this.compoundName,
    this.message,
    this.dockingMethod,
    this.dockingBoxMethod,
    this.analysisNotice,
    this.xlogp,
    this.tpsa,
    this.hydrogenBondDonors,
    this.hydrogenBondAcceptors,
    this.rotatableBonds,
    this.lipinskiStatus,
    this.lipinskiViolations = const <String>[],
    this.heavyAtomContactCount,
    this.residueContactCount,
    this.hydrophobicResidueContactCount,
    this.hydrogenBondCandidateCount,
    this.residueContacts = const <Map<String, dynamic>>[],
    this.hydrogenBondCandidates = const <Map<String, dynamic>>[],
    this.interactionMethod,
    this.ramachandranPoints = const <RamachandranPoint>[],
    this.ramachandranMessage,
  });

  String get formattedDockingScore {
    if (dockingScore == 'N/A' || dockingScore.trim().isEmpty) return 'N/A';
    if (dockingScore.contains('kcal/mol')) return dockingScore;
    return '$dockingScore kcal/mol';
  }

  String get formattedBindingAffinity {
    if (bindingAffinity != null &&
        bindingAffinity != 'Not calculated' &&
        bindingAffinity != 'Analysis not currently available' &&
        bindingAffinity != 'N/A' &&
        bindingAffinity!.trim().isNotEmpty) {
      return bindingAffinity!;
    }
    final cleanScore = dockingScore.replaceAll('kcal/mol', '').trim();
    final scoreVal = double.tryParse(cleanScore);
    if (scoreVal != null) {
      const rt = 0.59218; // RT in kcal/mol at 298.15 K
      final kdMolar = math.exp(scoreVal / rt);
      if (kdMolar >= 1e-3) {
        return '${(kdMolar * 1e3).toStringAsFixed(2)} mM (Est. Kd)';
      } else if (kdMolar >= 1e-6) {
        return '${(kdMolar * 1e6).toStringAsFixed(1)} µM (Est. Kd)';
      } else if (kdMolar >= 1e-9) {
        return '${(kdMolar * 1e9).toStringAsFixed(1)} nM (Est. Kd)';
      } else {
        return '${(kdMolar * 1e12).toStringAsFixed(1)} pM (Est. Kd)';
      }
    }
    return 'Not calculated';
  }

  factory DockingResult.fromJson(Map<String, dynamic> json) {
    String toText(dynamic value, [String fallback = 'Analysis not currently available']) {
      if (value == null) return fallback;
      final text = value.toString().trim();
      return text.isEmpty ? fallback : text;
    }

    double? toDouble(dynamic value) => value == null ? null : double.tryParse(value.toString());
    int? toInt(dynamic value) => value == null ? null : int.tryParse(value.toString());
    final descriptors = json['pubchem_descriptors'] is Map
        ? Map<String, dynamic>.from(json['pubchem_descriptors'] as Map)
        : json;
    final interaction = json['interaction_analysis'] is Map
        ? Map<String, dynamic>.from(json['interaction_analysis'] as Map)
        : <String, dynamic>{};
    final lipinski = json['lipinski_screen'] is Map
        ? Map<String, dynamic>.from(json['lipinski_screen'] as Map)
        : <String, dynamic>{};
    final rawPoints = json['ramachandran_points'] is List
        ? json['ramachandran_points'] as List
        : const <dynamic>[];
    final rawContacts = interaction['residue_contacts'] is List
        ? interaction['residue_contacts'] as List
        : const <dynamic>[];
    final rawBonds = interaction['hydrogen_bond_candidates'] is List
        ? interaction['hydrogen_bond_candidates'] as List
        : const <dynamic>[];
    final rawViolations = lipinski['violations'] is List
        ? lipinski['violations'] as List
        : const <dynamic>[];

    return DockingResult(
      proteinName: toText(json['protein_name'] ?? json['proteinName'] ?? json['protein'], 'Protein not available'),
      ligandName: toText(json['ligand_name'] ?? json['ligandName'] ?? json['ligand'], 'Ligand not available'),
      proteinId: toText(json['protein_id'] ?? json['proteinId'] ?? json['pdb_id'] ?? json['pdbId'], 'PDB ID not available'),
      molecularFormula: toText(json['molecular_formula'] ?? json['molecularFormula'], 'Analysis not currently available'),
      molecularWeight: toText(json['molecular_weight'] ?? json['molecularWeight'], 'Analysis not currently available'),
      canonicalSmiles: toText(json['canonical_smiles'] ?? json['canonicalSmiles'], 'Analysis not currently available'),
      dockingScore: toText(json['docking_score'] ?? json['dockingScore'] ?? 'N/A', 'N/A'),
      bindingAffinity: toText(json['binding_affinity'] ?? json['bindingAffinity'], 'Not calculated'),
      interactionStatus: toText(json['interaction_status'] ?? json['interactionStatus'], 'Interaction calculation is not currently available.'),
      absorption: toText(json['absorption'], 'Analysis not currently available'),
      distribution: toText(json['distribution'], 'Analysis not currently available'),
      metabolism: toText(json['metabolism'], 'Analysis not currently available'),
      excretion: toText(json['excretion'], 'Analysis not currently available'),
      toxicity: toText(json['toxicity'] ?? json['toxicity_risk'], 'Analysis not currently available'),
      drugLikeness: toText(lipinski['status'] ?? json['drug_likeness'] ?? json['drugLikeness'], 'Analysis not currently available'),
      proteinOrganism: toText(json['organism'], 'Analysis not currently available'),
      experimentalMethod: toText(json['experimental_method'] ?? json['experimentalMethod'], 'Analysis not currently available'),
      resolution: toText(json['resolution'], 'Analysis not currently available'),
      ramachandranFavored: toText(json['ramachandran_favored'] ?? json['ramachandranFavored'], 'Analysis not currently available'),
      ramachandranAllowed: toText(json['ramachandran_allowed'] ?? json['ramachandranAllowed'], 'Analysis not currently available'),
      ramachandranOutlier: toText(json['ramachandran_outlier'] ?? json['ramachandranOutlier'], 'Analysis not currently available'),
      ligandCid: toText(json['cid'] ?? json['ligand_cid'] ?? json['compound_cid'] ?? json['compound_id'], 'Analysis not currently available'),
      compoundName: toText(json['compound_name'] ?? json['compoundName'] ?? json['ligand_name'] ?? json['ligand'], 'Analysis not currently available'),
      message: toText(json['message'], 'Analysis not currently available'),
      dockingMethod: toText(json['docking_method'], 'Analysis not currently available'),
      dockingBoxMethod: toText(json['docking_box_method'], 'Analysis not currently available'),
      analysisNotice: toText(json['analysis_notice'], 'Analysis not currently available'),
      xlogp: toDouble(descriptors['xlogp'] ?? descriptors['XLogP']),
      tpsa: toDouble(descriptors['tpsa'] ?? descriptors['TPSA']),
      hydrogenBondDonors: toInt(descriptors['hydrogen_bond_donors'] ?? descriptors['HBondDonorCount']),
      hydrogenBondAcceptors: toInt(descriptors['hydrogen_bond_acceptors'] ?? descriptors['HBondAcceptorCount']),
      rotatableBonds: toInt(descriptors['rotatable_bonds'] ?? descriptors['RotatableBondCount']),
      lipinskiStatus: toText(lipinski['status'], 'Analysis not currently available'),
      lipinskiViolations: rawViolations.map((item) {
        if (item is Map) {
          final violation = Map<String, dynamic>.from(item);
          return '${violation['descriptor']}: ${violation['observed']}';
        }
        return item.toString();
      }).toList(),
      heavyAtomContactCount: toInt(interaction['heavy_atom_contact_count']),
      residueContactCount: toInt(interaction['residue_contact_count']),
      hydrophobicResidueContactCount: toInt(interaction['hydrophobic_residue_contact_count']),
      hydrogenBondCandidateCount: toInt(interaction['hydrogen_bond_candidate_count']),
      residueContacts: rawContacts.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(),
      hydrogenBondCandidates: rawBonds.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(),
      interactionMethod: toText(interaction['method'], 'Analysis not currently available'),
      ramachandranPoints: rawPoints.whereType<Map>().map((item) => RamachandranPoint.fromJson(Map<String, dynamic>.from(item))).toList(),
      ramachandranMessage: toText(json['ramachandran_message'], 'Analysis not currently available'),
    );
  }

  Map<String, dynamic> toJson() => {
        'protein_name': proteinName,
        'ligand_name': ligandName,
        'protein_id': proteinId,
        'molecular_formula': molecularFormula,
        'molecular_weight': molecularWeight,
        'canonical_smiles': canonicalSmiles,
        'docking_score': dockingScore,
        'binding_affinity': bindingAffinity,
        'interaction_status': interactionStatus,
        'absorption': absorption,
        'distribution': distribution,
        'metabolism': metabolism,
        'excretion': excretion,
        'toxicity': toxicity,
        'drug_likeness': drugLikeness,
        'protein_organism': proteinOrganism,
        'experimental_method': experimentalMethod,
        'resolution': resolution,
        'ramachandran_favored': ramachandranFavored,
        'ramachandran_allowed': ramachandranAllowed,
        'ramachandran_outlier': ramachandranOutlier,
        'ligand_cid': ligandCid,
        'compound_name': compoundName,
        'docking_method': dockingMethod,
        'docking_box_method': dockingBoxMethod,
        'analysis_notice': analysisNotice,
        'pubchem_descriptors': {
          'xlogp': xlogp,
          'tpsa': tpsa,
          'hydrogen_bond_donors': hydrogenBondDonors,
          'hydrogen_bond_acceptors': hydrogenBondAcceptors,
          'rotatable_bonds': rotatableBonds,
        },
        'lipinski_screen': {
          'status': lipinskiStatus,
          'violations': lipinskiViolations,
        },
        'interaction_analysis': {
          'heavy_atom_contact_count': heavyAtomContactCount,
          'residue_contact_count': residueContactCount,
          'hydrophobic_residue_contact_count': hydrophobicResidueContactCount,
          'hydrogen_bond_candidate_count': hydrogenBondCandidateCount,
          'residue_contacts': residueContacts,
          'hydrogen_bond_candidates': hydrogenBondCandidates,
          'method': interactionMethod,
        },
        'ramachandran_points': ramachandranPoints.map((point) => point.toJson()).toList(),
        'ramachandran_message': ramachandranMessage,
      };
}

class RamachandranPoint {
  final String chain;
  final int residueNumber;
  final String residueName;
  final double phi;
  final double psi;

  const RamachandranPoint({
    required this.chain,
    required this.residueNumber,
    required this.residueName,
    required this.phi,
    required this.psi,
  });

  factory RamachandranPoint.fromJson(Map<String, dynamic> json) {
    return RamachandranPoint(
      chain: (json['chain'] ?? '').toString(),
      residueNumber: int.tryParse(json['residue_number'].toString()) ?? 0,
      residueName: (json['residue_name'] ?? '').toString(),
      phi: double.tryParse(json['phi'].toString()) ?? 0,
      psi: double.tryParse(json['psi'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'chain': chain,
        'residue_number': residueNumber,
        'residue_name': residueName,
        'phi': phi,
        'psi': psi,
      };
}
