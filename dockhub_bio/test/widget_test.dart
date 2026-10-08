// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dockhub_bio/app.dart';
import 'package:dockhub_bio/models/docking_result.dart';
import 'package:dockhub_bio/models/history_item.dart';
import 'package:dockhub_bio/pages/dashboard_page.dart';
import 'package:dockhub_bio/pages/admet_page.dart';
import 'package:dockhub_bio/pages/drug_likeness_page.dart';
import 'package:dockhub_bio/pages/interaction_page.dart';
import 'package:dockhub_bio/pages/my_profile_page.dart';
import 'package:dockhub_bio/pages/ramachandran_page.dart';
import 'package:dockhub_bio/pages/docking_summary_page.dart';

void main() {
  testWidgets('DockHub Bio app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DockHubBioApp());

    expect(find.text('DockHub Bio'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to DockHub Bio'), findsOneWidget);
  });

  testWidgets('Docking summary actions invoke navigation and save callbacks', (WidgetTester tester) async {
    final destinations = <int>[];
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: DockingSummaryPage(
          result: const DockingResult(
            proteinName: 'Test protein',
            ligandName: 'Test ligand',
            proteinId: 'PDB1',
            dockingScore: '-1.0',
            interactionStatus: 'Not available',
          ),
          onNavigate: destinations.add,
          onSave: () => saved = true,
        ),
      ),
    );

    for (final action in [
      ('View Protein', 7),
      ('View Ligand', 8),
      ('View Interactions', 9),
      ('View ADMET', 10),
      ('View Ramachandran', 12),
      ('View Complete Report', 18),
    ]) {
      final button = find.text(action.$1);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }

    final saveButton = find.text('Save Result');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    expect(destinations, [7, 8, 9, 10, 12, 18]);
    expect(saved, isTrue);
  });

  test('DockingResult maps live PDB and PubChem response fields', () {
    final result = DockingResult.fromJson({
      'protein_name': 'insulin',
      'protein_id': '1ZNI',
      'organism': 'Sus scrofa',
      'experimental_method': 'X-RAY DIFFRACTION',
      'resolution': 1.498,
      'ligand_name': 'curcumin',
      'compound_cid': '969516',
      'molecular_formula': 'C21H20O6',
      'molecular_weight': 368.4,
      'canonical_smiles': 'COC1=CC=CC=C1',
      'docking_score': -5.778,
      'binding_affinity': 'Not calculated',
      'analysis_notice': 'ADMET was not calculated.',
      'pubchem_descriptors': {
        'xlogp': 3.2,
        'tpsa': 93.1,
        'hydrogen_bond_donors': 2,
        'hydrogen_bond_acceptors': 6,
        'rotatable_bonds': 8,
      },
      'lipinski_screen': {
        'status': 'No Lipinski Rule-of-Five violations',
        'violations': [],
      },
      'interaction_analysis': {
        'heavy_atom_contact_count': 72,
        'residue_contact_count': 8,
        'hydrophobic_residue_contact_count': 4,
        'hydrogen_bond_candidate_count': 2,
        'hydrogen_bond_candidates': [
          {'ligand_atom': 'O', 'protein_atom': 'N', 'residue': 'A:ASN2', 'distance_angstrom': 3.1},
        ],
        'residue_contacts': [
          {'residue': 'A:ASN2', 'atom_contacts': 5, 'minimum_distance_angstrom': 2.9},
        ],
        'method': 'PDBQT atom-distance screen',
      },
      'ramachandran_message': 'Angles computed from PDB coordinates.',
      'ramachandran_points': [
        {'chain': 'A', 'residue_number': 2, 'residue_name': 'ASN', 'phi': -71.14, 'psi': -27.12},
      ],
    });

    expect(result.proteinOrganism, 'Sus scrofa');
    expect(result.experimentalMethod, 'X-RAY DIFFRACTION');
    expect(result.resolution, '1.498');
    expect(result.ligandCid, '969516');
    expect(result.molecularFormula, 'C21H20O6');
    expect(result.canonicalSmiles, 'COC1=CC=CC=C1');
    expect(result.dockingScore, '-5.778');
    expect(result.bindingAffinity, 'Not calculated');
    expect(result.drugLikeness, 'No Lipinski Rule-of-Five violations');
    expect(result.analysisNotice, 'ADMET was not calculated.');
    expect(result.xlogp, 3.2);
    expect(result.tpsa, 93.1);
    expect(result.hydrogenBondDonors, 2);
    expect(result.lipinskiStatus, 'No Lipinski Rule-of-Five violations');
    expect(result.heavyAtomContactCount, 72);
    expect(result.residueContacts.single['residue'], 'A:ASN2');
    expect(result.hydrogenBondCandidates.single['distance_angstrom'], 3.1);
    expect(result.ramachandranPoints.single.phi, -71.14);
    expect(result.toJson()['interaction_analysis']['residue_contacts'], isNotEmpty);
  });

  testWidgets('Dashboard displays activity counts and recent docking history', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardPage(
          userName: 'Ada Lovelace',
          history: [
            HistoryItem(
              protein: 'Keratin',
              pdbId: '9VHS',
              ligand: 'Curcumin',
              dockingScore: '-5.804',
              dateTime: DateTime(2026),
            ),
          ],
          savedCount: 2,
          proteinSearchCount: 3,
          ligandSearchCount: 4,
          onQuickDock: () {},
          onProteinSearch: () {},
          onLigandSearch: () {},
          ),
        ),
      ),
    );

    expect(find.text('Welcome back, Ada Lovelace'), findsOneWidget);
    expect(find.text('Total Docking Studies'), findsOneWidget);
    expect(find.text('Keratin / Curcumin'), findsOneWidget);
    expect(find.text('-5.804'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Profile displays the name and email returned at login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyProfilePage(
          name: 'Ada Lovelace',
          email: 'ada@example.org',
          onSave: (name, email) async {},
        ),
      ),
    );

    expect(find.text('Ada Lovelace').first, findsOneWidget);
    expect(find.text('ada@example.org'), findsOneWidget);
    expect(find.text('Login email'), findsOneWidget);
  });

  testWidgets('Analysis views render measured descriptors, contacts, and torsions', (WidgetTester tester) async {
    final result = DockingResult.fromJson({
      'protein_name': 'Test protein',
      'protein_id': '1ABC',
      'ligand_name': 'Test ligand',
      'compound_cid': '12345',
      'molecular_formula': 'C10H12O',
      'molecular_weight': 148.2,
      'docking_score': -6.2,
      'pubchem_descriptors': {
        'xlogp': 2.1,
        'tpsa': 20.2,
        'hydrogen_bond_donors': 1,
        'hydrogen_bond_acceptors': 2,
        'rotatable_bonds': 3,
      },
      'lipinski_screen': {'status': 'No Lipinski Rule-of-Five violations', 'violations': []},
      'interaction_analysis': {
        'heavy_atom_contact_count': 12,
        'residue_contact_count': 2,
        'hydrophobic_residue_contact_count': 1,
        'hydrogen_bond_candidate_count': 1,
        'residue_contacts': [
          {'residue': 'A:SER10', 'atom_contacts': 6, 'minimum_distance_angstrom': 3.1},
        ],
        'hydrogen_bond_candidates': [
          {'ligand_atom': 'O1', 'protein_atom': 'N', 'residue': 'A:SER10', 'distance_angstrom': 3.0},
        ],
        'method': 'Distance screen',
      },
      'ramachandran_message': 'Angles from PDB coordinates.',
      'ramachandran_points': [
        {'chain': 'A', 'residue_number': 10, 'residue_name': 'SER', 'phi': -60.0, 'psi': -40.0},
      ],
    });

    await tester.pumpWidget(MaterialApp(home: InteractionPage(result: result)));
    expect(find.text('12'), findsOneWidget);
    expect(find.text('A:SER10'), findsNWidgets(2));

    await tester.pumpWidget(MaterialApp(home: AdmetPage(result: result)));
    expect(find.text('2.10'), findsOneWidget);
    expect(find.text('20.2 A^2'), findsOneWidget);
    expect(find.text('No ADMET or toxicity model was run for this result.'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: DrugLikenessPage(result: result)));
    expect(find.text('No Lipinski Rule-of-Five violations'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: RamachandranPage(result: result)));
    await tester.pump();
    expect(find.text('1 residue angle pairs'), findsOneWidget);
    expect(find.textContaining('SER10'), findsOneWidget);
  });
}
