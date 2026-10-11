import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';

class StorageService {
  static const String historyKey = 'dockhub_history';
  static const String savedResultsKey = 'dockhub_saved_results';
  static const String profileKey = 'dockhub_profile';
  static const String settingsKey = 'dockhub_settings';
  static const String proteinSearchesKey = 'dockhub_protein_searches';
  static const String ligandSearchesKey = 'dockhub_ligand_searches';

  static String _accountKey(String key, String userEmail) =>
      '$key:${userEmail.trim().toLowerCase()}';

  static Future<int> recordProteinSearch(String query, String userEmail) {
    return _recordUniqueSearch(_accountKey(proteinSearchesKey, userEmail), query);
  }

  static Future<int> recordLigandSearch(String query, String userEmail) {
    return _recordUniqueSearch(_accountKey(ligandSearchesKey, userEmail), query);
  }

  static Future<int> loadProteinSearchCount(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_accountKey(proteinSearchesKey, userEmail))?.length ?? 0;
  }

  static Future<int> loadLigandSearchCount(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_accountKey(ligandSearchesKey, userEmail))?.length ?? 0;
  }

  static Future<int> _recordUniqueSearch(String key, String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return 0;

    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(key) ?? <String>[];
    if (!searches.contains(normalized)) {
      searches.add(normalized);
      await prefs.setStringList(key, searches);
    }
    return searches.length;
  }

  static Future<List<HistoryItem>> loadHistory(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final accountKey = _accountKey(historyKey, userEmail);
    final raw = prefs.getString(accountKey) ?? prefs.getString(historyKey) ?? '[]';
    if (!prefs.containsKey(accountKey) && prefs.containsKey(historyKey)) {
      await prefs.setString(accountKey, raw);
      await prefs.remove(historyKey);
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <HistoryItem>[];
    return decoded
        .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveHistory(String userEmail, List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey(historyKey, userEmail), jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<List<SavedResult>> loadSavedResults(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final accountKey = _accountKey(savedResultsKey, userEmail);
    final raw = prefs.getString(accountKey) ?? prefs.getString(savedResultsKey) ?? '[]';
    if (!prefs.containsKey(accountKey) && prefs.containsKey(savedResultsKey)) {
      await prefs.setString(accountKey, raw);
      await prefs.remove(savedResultsKey);
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <SavedResult>[];
    return decoded
        .map((item) => SavedResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveSavedResults(String userEmail, List<SavedResult> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey(savedResultsKey, userEmail), jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(profileKey) ?? '{}';
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {'name': 'DockHub User', 'email': 'user@dockhub.bio'};
    return decoded;
  }

  static Future<void> saveProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileKey, jsonEncode({'name': name, 'email': email}));
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(settingsKey) ?? '{}';
    final decoded = jsonDecode(raw);
    const defaults = {'animations': true, 'theme': 'Dark', 'notifications': true, 'language': 'en'};
    if (decoded is! Map<String, dynamic>) return defaults;
    return {...defaults, ...decoded};
  }

  static Future<void> saveSettings({
    required bool animations,
    required String theme,
    required bool notifications,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(settingsKey, jsonEncode({
      'animations': animations,
      'theme': theme,
      'notifications': notifications,
      'language': language,
    }));
  }

  static Future<String?> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dockhub_server_url');
  }

  static Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dockhub_server_url', url.trim());
  }
}
