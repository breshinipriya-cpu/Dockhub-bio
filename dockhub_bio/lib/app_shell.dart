import 'dart:convert';
import 'package:flutter/material.dart';

import 'models/docking_result.dart';
import 'models/history_item.dart';
import 'pages/admet_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/docking_summary_page.dart';
import 'pages/drug_likeness_page.dart';
import 'pages/history_page.dart';
import 'pages/interaction_page.dart';
import 'pages/language_page.dart';
import 'pages/ligand_details_page.dart';
import 'pages/ligand_search_page.dart';
import 'pages/molecular_structure_page.dart';
import 'pages/my_profile_page.dart';
import 'pages/new_docking_page.dart';
import 'pages/protein_details_page.dart';
import 'pages/protein_search_page.dart';
import 'pages/ramachandran_page.dart';
import 'pages/report_page.dart';
import 'pages/saved_results_page.dart';
import 'pages/settings_page.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  String _language = 'en';
  String _theme = 'Dark';
  bool _animations = true;
  bool _notificationsEnabled = true;
  String _userName = 'DockHub User';
  String _userEmail = '';
  DockingResult? _latestResult;
  List<HistoryItem> _history = <HistoryItem>[];
  List<SavedResult> _saved = <SavedResult>[];
  int _proteinSearchCount = 0;
  int _ligandSearchCount = 0;

  // Map sidebar tab indices (0..18) to IndexedStack page indices (0..15)
  final Map<int, int> _tabToIndexMap = const {
    0: 0,   // Dashboard
    1: 1,   // New Docking
    2: 2,   // Protein Search
    3: 3,   // Ligand Search
    4: 4,   // History
    5: 5,   // Saved Results
    6: 6,   // Docking Summary
    7: 7,   // Protein Details
    8: 8,   // Ligand Details
    9: 9,   // Interactions
    10: 10, // ADMET
    11: 11, // Drug-Likeness
    12: 12, // Ramachandran
    13: 13, // Molecular Structure
    14: 14, // My Profile
    15: 15, // Settings
    16: 16, // Language
    18: 17, // Complete Report
  };

  @override
  void initState() {
    super.initState();
    _loadProfileAndSettings();
  }

  Future<void> _loadProfileAndSettings() async {
    final profile = await StorageService.loadProfile();
    final settings = await StorageService.loadSettings();
    if (!mounted) return;
    setState(() {
      _userName = (profile['name'] ?? 'DockHub User').toString();
      _userEmail = (profile['email'] ?? '').toString();
      _language = (settings['language'] ?? 'en').toString();
      _theme = (settings['theme'] ?? 'Dark').toString();
      _animations = settings['animations'] != false;
      _notificationsEnabled = settings['notifications'] != false;
    });
    await _loadHistoryAndSaved();
  }

  Future<void> _loadHistoryAndSaved() async {
    final localHistory = await StorageService.loadHistory(_userEmail);
    final localSaved = await StorageService.loadSavedResults(_userEmail);
    List<HistoryItem> history = localHistory;
    List<SavedResult> saved = localSaved;

    if (_userEmail.isNotEmpty) {
      try {
        final historyResponse = await ApiService.loadHistory(_userEmail);
        if (historyResponse['success'] == true && historyResponse['items'] is List) {
          final remoteHistory = (historyResponse['items'] as List)
              .whereType<Map>()
              .map((item) => HistoryItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          history = [
            ...remoteHistory,
            ...localHistory.where((local) => local.resultJson != null &&
                !remoteHistory.any((remote) => remote.resultJson == local.resultJson)),
          ];
          await StorageService.saveHistory(_userEmail, history);
        }
      } catch (_) {}

      try {
        final savedResponse = await ApiService.loadSavedResults(_userEmail);
        if (savedResponse['success'] == true && savedResponse['items'] is List) {
          final remoteSaved = (savedResponse['items'] as List)
              .whereType<Map>()
              .map((item) => SavedResult.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          final knownResults = remoteSaved.map((item) => item.resultJson).toSet();
          for (final local in localSaved.where((item) => !knownResults.contains(item.resultJson))) {
            try {
              final decoded = jsonDecode(local.resultJson);
              if (decoded is Map<String, dynamic>) {
                await ApiService.saveSavedResult(
                  userEmail: _userEmail,
                  result: decoded,
                  createdAt: local.dateTime.toIso8601String(),
                );
              }
            } catch (_) {}
          }
          final refreshed = await ApiService.loadSavedResults(_userEmail);
          if (refreshed['success'] == true && refreshed['items'] is List) {
            saved = (refreshed['items'] as List)
                .whereType<Map>()
                .map((item) => SavedResult.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          } else {
            saved = remoteSaved;
          }
          await StorageService.saveSavedResults(_userEmail, saved);
        }
      } catch (_) {}
    }

    var proteinSearchCount = await StorageService.loadProteinSearchCount(_userEmail);
    var ligandSearchCount = await StorageService.loadLigandSearchCount(_userEmail);
    try {
      final stats = await ApiService.loadDashboardStats(_userEmail);
      if (stats['success'] == true) {
        proteinSearchCount = (stats['protein_search_count'] as num?)?.toInt() ?? proteinSearchCount;
        ligandSearchCount = (stats['ligand_search_count'] as num?)?.toInt() ?? ligandSearchCount;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _history = history;
      _saved = saved;
      _proteinSearchCount = proteinSearchCount;
      _ligandSearchCount = ligandSearchCount;
    });
  }

  Future<void> _recordDockingResult(DockingResult result) async {
    final historyItem = HistoryItem(
      protein: result.proteinName,
      pdbId: result.proteinId,
      ligand: result.ligandName,
      dockingScore: result.dockingScore,
      dateTime: DateTime.now(),
      resultJson: jsonEncode(result.toJson()),
    );
    final updatedHistory = [historyItem, ..._history];
    await StorageService.saveHistory(_userEmail, updatedHistory);
    if (!mounted) return;
    setState(() {
      _latestResult = result;
      _history = updatedHistory;
      _selectedIndex = 6;
    });
  }

  Future<void> _recordProteinSearch(String query) async {
    final count = await StorageService.recordProteinSearch(query, _userEmail);
    try {
      await ApiService.recordSearch(userEmail: _userEmail, searchType: 'protein', query: query);
      final stats = await ApiService.loadDashboardStats(_userEmail);
      if (stats['success'] == true) {
        if (mounted) setState(() => _proteinSearchCount = (stats['protein_search_count'] as num?)?.toInt() ?? count);
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _proteinSearchCount = count);
  }

  Future<void> _recordLigandSearch(String query) async {
    final count = await StorageService.recordLigandSearch(query, _userEmail);
    try {
      await ApiService.recordSearch(userEmail: _userEmail, searchType: 'ligand', query: query);
      final stats = await ApiService.loadDashboardStats(_userEmail);
      if (stats['success'] == true) {
        if (mounted) setState(() => _ligandSearchCount = (stats['ligand_search_count'] as num?)?.toInt() ?? count);
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _ligandSearchCount = count);
  }

  Future<void> _updateProfile(String name, String email) async {
    await StorageService.saveProfile(name, email);
    if (!mounted) return;
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _savePreferences() async {
    await StorageService.saveSettings(
      animations: _animations,
      theme: _theme,
      notifications: _notificationsEnabled,
      language: _language,
    );
  }

  Future<void> _updateTheme(String theme) async {
    setState(() => _theme = theme);
    await _savePreferences();
  }

  Future<void> _updateAnimations(bool enabled) async {
    setState(() => _animations = enabled);
    await _savePreferences();
  }

  Future<void> _updateNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _savePreferences();
  }

  Future<void> _updateLanguage(String language) async {
    setState(() => _language = language);
    await _savePreferences();
  }

  void _showFeedback(String message) {
    if (!_notificationsEnabled || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _clearHistory() async {
    try {
      final response = await ApiService.clearHistory(_userEmail);
      if (response['success'] != true) throw StateError('History could not be cleared on the server.');
      await StorageService.saveHistory(_userEmail, <HistoryItem>[]);
      if (!mounted) return;
      setState(() => _history = <HistoryItem>[]);
      _showFeedback('Docking history cleared.');
    } catch (_) {
      _showFeedback('Could not clear server history. Check the backend connection.');
    }
  }

  Future<void> _clearSavedResults() async {
    try {
      final response = await ApiService.clearSavedResults(_userEmail);
      if (response['success'] != true) throw StateError('Saved results could not be cleared on the server.');
      await StorageService.saveSavedResults(_userEmail, <SavedResult>[]);
      if (!mounted) return;
      setState(() => _saved = <SavedResult>[]);
      _showFeedback('Saved results cleared.');
    } catch (_) {
      _showFeedback('Could not clear server saved results. Check the backend connection.');
    }
  }

  Future<void> _saveCurrentResult() async {
    final result = _latestResult;
    if (result == null) return;

    final resultJson = jsonEncode(result.toJson());
    if (_saved.any((item) => item.resultJson == resultJson)) {
      _showFeedback('This result is already saved.');
      return;
    }

    final updatedSaved = [
      ..._saved,
      SavedResult(
        protein: result.proteinName,
        pdbId: result.proteinId,
        ligand: result.ligandName,
        dockingScore: result.dockingScore,
        dateTime: DateTime.now(),
        resultJson: resultJson,
      ),
    ];
    final timestamp = DateTime.now();
    try {
      final response = await ApiService.saveSavedResult(
        userEmail: _userEmail,
        result: result.toJson(),
        createdAt: timestamp.toIso8601String(),
      );
      if (response['success'] != true) throw StateError('Server save failed.');
    } catch (_) {
      _showFeedback('Could not save to your account. Check the backend connection.');
      return;
    }
    await StorageService.saveSavedResults(_userEmail, updatedSaved);
    if (!mounted) return;
    setState(() => _saved = updatedSaved);
    _showFeedback('Result saved to your account.');
  }

  void _changePage(int index) {
    if (index == 17) {
      _showLogoutConfirmation();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  String _getPageTitle(int index) {
    const titles = <int, String>{
      0: 'Dashboard',
      1: 'New Docking',
      2: 'Protein Search',
      3: 'Ligand Search',
      4: 'History',
      5: 'Saved Results',
      6: 'Docking Summary',
      7: 'Protein Details',
      8: 'Ligand Details',
      9: 'Interactions',
      10: 'ADMET Analysis',
      11: 'Drug-Likeness',
      12: 'Ramachandran Plot',
      13: '3D Molecular Structure',
      14: 'My Profile',
      15: 'Settings',
      16: 'Language Settings',
      18: 'Complete Report',
    };
    return titles[index] ?? 'DockHub Bio';
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.getTheme(_theme);

    final stackIndex = _tabToIndexMap[_selectedIndex] ?? 0;

    final defaultResult = _latestResult ?? const DockingResult(
      proteinName: 'Protein not available',
      ligandName: 'Ligand not available',
      proteinId: 'N/A',
      dockingScore: 'N/A',
      interactionStatus: 'Analysis not currently available',
    );

    final isMobile = MediaQuery.of(context).size.width < 700;

    final bodyStack = IndexedStack(
      index: stackIndex,
      children: [
        DashboardPage(
          key: const PageStorageKey('dashboard_page'),
          userName: _userName,
          history: _history,
          savedCount: _saved.length,
          proteinSearchCount: _proteinSearchCount,
          ligandSearchCount: _ligandSearchCount,
          onQuickDock: () => setState(() => _selectedIndex = 1),
          onProteinSearch: () => setState(() => _selectedIndex = 2),
          onLigandSearch: () => setState(() => _selectedIndex = 3),
        ),
        NewDockingPage(
          key: const PageStorageKey('new_docking_page'),
          userEmail: _userEmail,
          onAnalyze: _recordDockingResult,
        ),
        ProteinSearchPage(
          key: const PageStorageKey('protein_search_page'),
          onSearchSuccess: _recordProteinSearch,
        ),
        LigandSearchPage(
          key: const PageStorageKey('ligand_search_page'),
          onSearchSuccess: _recordLigandSearch,
        ),
        HistoryPage(
          key: const PageStorageKey('history_page'),
          history: _history,
          onOpen: (item) {
            final result = DockingResult.fromJson(jsonDecode(item.resultJson ?? '{}'));
            setState(() {
              _latestResult = result;
              _selectedIndex = 6;
            });
          },
        ),
        SavedResultsPage(
          key: const PageStorageKey('saved_results_page'),
          saved: _saved,
          onOpen: (item) {
            final result = DockingResult.fromJson(jsonDecode(item.resultJson));
            setState(() {
              _latestResult = result;
              _selectedIndex = 6;
            });
          },
        ),
        DockingSummaryPage(
          key: const PageStorageKey('docking_summary_page'),
          result: defaultResult,
          onNavigate: _changePage,
          onSave: _saveCurrentResult,
        ),
        ProteinDetailsPage(
          key: const PageStorageKey('protein_details_page'),
          result: _latestResult,
        ),
        LigandDetailsPage(
          key: const PageStorageKey('ligand_details_page'),
          result: _latestResult,
        ),
        InteractionPage(
          key: const PageStorageKey('interaction_page'),
          result: _latestResult,
        ),
        AdmetPage(
          key: const PageStorageKey('admet_page'),
          result: _latestResult,
        ),
        DrugLikenessPage(
          key: const PageStorageKey('drug_likeness_page'),
          result: _latestResult,
        ),
        RamachandranPage(
          key: const PageStorageKey('ramachandran_page'),
          result: _latestResult,
        ),
        MolecularStructurePage(
          key: const PageStorageKey('molecular_structure_page'),
          result: _latestResult,
        ),
        MyProfilePage(
          key: const PageStorageKey('my_profile_page'),
          name: _userName,
          email: _userEmail,
          onSave: _updateProfile,
        ),
        SettingsPage(
          key: const PageStorageKey('settings_page'),
          theme: _theme,
          animationsEnabled: _animations,
          notificationsEnabled: _notificationsEnabled,
          onThemeChanged: _updateTheme,
          onAnimationsChanged: _updateAnimations,
          onNotificationsChanged: _updateNotifications,
          onClearHistory: _clearHistory,
          onClearSavedResults: _clearSavedResults,
        ),
        LanguagePage(
          key: const PageStorageKey('language_page'),
          selectedLanguage: _language,
          onSelect: _updateLanguage,
        ),
        ReportPage(
          key: const PageStorageKey('report_page'),
          result: _latestResult,
          onSave: _saveCurrentResult,
        ),
      ],
    );

    if (isMobile) {
      return Theme(
        data: appTheme,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appTheme.colorScheme.surface,
            title: Row(
              children: [
                Icon(Icons.biotech_rounded, color: appTheme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  _getPageTitle(_selectedIndex),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            elevation: 1,
          ),
          drawer: Drawer(
            child: DockSidebar(
              selectedIndex: _selectedIndex,
              onChanged: (index) {
                Navigator.of(context).pop();
                _changePage(index);
              },
              onLogout: () {
                Navigator.of(context).pop();
                _showLogoutConfirmation();
              },
              language: _language,
            ),
          ),
          body: bodyContent(bodyStack),
        ),
      );
    }

    return Theme(
      data: appTheme,
      child: Scaffold(
        body: Row(
          children: [
            DockSidebar(
              selectedIndex: _selectedIndex,
              onChanged: _changePage,
              onLogout: _showLogoutConfirmation,
              language: _language,
            ),
            Expanded(
              child: bodyStack,
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyContent(Widget child) => child;
}
