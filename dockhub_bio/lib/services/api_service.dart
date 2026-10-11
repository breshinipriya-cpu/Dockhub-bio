import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String _overrideBaseUrl = '';

  static String get cloudUrl => 'https://dockhub-backend.onrender.com';
  static String get localUrl => 'http://127.0.0.1:8000';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.137.1:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static set baseUrl(String url) {
    _overrideBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static bool get isLocal => baseUrl.contains('127.0.0.1') || baseUrl.contains('localhost') || baseUrl.contains('192.168.');

  static void useLocalBackend() {
    _overrideBaseUrl = localUrl;
  }

  static void useCloudBackend() {
    _overrideBaseUrl = cloudUrl;
  }

  static Future<bool> pingServer([String? url]) async {
    final target = url ?? baseUrl;
    try {
      final res = await http.get(Uri.parse('$target/')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static const Duration requestTimeout = Duration(seconds: 35);

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _safePost(
      '$baseUrl/login',
      {'email': email.trim(), 'password': password.trim()},
    );
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return _safePost(
      '$baseUrl/signup',
      {
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
      },
    );
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    return _safePost(
      '$baseUrl/forgot-password',
      {'email': email.trim()},
    );
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    return _safePost(
      '$baseUrl/reset-password',
      {
        'email': email.trim(),
        'token': token.trim(),
        'new_password': newPassword.trim(),
      },
    );
  }

  static Future<Map<String, dynamic>> analyze({
    required String protein,
    required String ligand,
    required String userEmail,
  }) async {
    final params = {
      'protein': protein.trim(),
      'ligand': ligand.trim(),
      'user_email': userEmail.trim(),
    };

    final uri = Uri.parse('$baseUrl/analyze').replace(queryParameters: params);
    var result = await _safeGet(uri, timeout: const Duration(seconds: 45));

    // AUTO-FAILOVER: If request failed or timed out on primary backend:
    if (result['success'] == false) {
      // 1. If currently on cloud, try local backend if accessible
      if (!isLocal) {
        try {
          final localUri = Uri.parse('$localUrl/analyze').replace(queryParameters: params);
          final localResp = await http.get(localUri).timeout(const Duration(seconds: 30));
          final decoded = _decode(localResp);
          if (decoded['success'] == true) {
            _overrideBaseUrl = localUrl;
            return decoded;
          }
        } catch (_) {}
      } else {
        // 2. If currently on local, try cloud backend
        try {
          final cloudUri = Uri.parse('$cloudUrl/analyze').replace(queryParameters: params);
          final cloudResp = await http.get(cloudUri).timeout(const Duration(seconds: 45));
          final decoded = _decode(cloudResp);
          if (decoded['success'] == true) {
            _overrideBaseUrl = cloudUrl;
            return decoded;
          }
        } catch (_) {}
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>> searchProtein(String query) async {
    final uri = Uri.parse('$baseUrl/search_protein?query=${Uri.encodeComponent(query.trim())}');
    return _safeGetWithFallback(uri, '/search_protein?query=${Uri.encodeComponent(query.trim())}');
  }

  static Future<Map<String, dynamic>> searchLigand(String query) async {
    final uri = Uri.parse('$baseUrl/search_ligand?query=${Uri.encodeComponent(query.trim())}');
    return _safeGetWithFallback(uri, '/search_ligand?query=${Uri.encodeComponent(query.trim())}');
  }

  static Future<Map<String, dynamic>> loadHistory(String userEmail) async {
    final path = '/history?user_email=${Uri.encodeComponent(userEmail)}';
    return _safeGetWithFallback(Uri.parse('$baseUrl$path'), path);
  }

  static Future<Map<String, dynamic>> clearHistory(String userEmail) async {
    final uri = Uri.parse('$baseUrl/history').replace(queryParameters: {'user_email': userEmail});
    return _safeDelete(uri);
  }

  static Future<Map<String, dynamic>> loadSavedResults(String userEmail) async {
    final path = '/saved_results?user_email=${Uri.encodeComponent(userEmail)}';
    return _safeGetWithFallback(Uri.parse('$baseUrl$path'), path);
  }

  static Future<Map<String, dynamic>> saveSavedResult({
    required String userEmail,
    required Map<String, dynamic> result,
    required String createdAt,
  }) async {
    return _safePost(
      '$baseUrl/saved_results',
      {
        'user_email': userEmail,
        'protein': result['protein_name'],
        'protein_id': result['protein_id'],
        'ligand': result['ligand_name'],
        'docking_score': result['docking_score'].toString(),
        'created_at': createdAt,
        'result_json': jsonEncode(result),
      },
    );
  }

  static Future<Map<String, dynamic>> clearSavedResults(String userEmail) async {
    final uri = Uri.parse('$baseUrl/saved_results').replace(queryParameters: {'user_email': userEmail});
    return _safeDelete(uri);
  }

  static Future<Map<String, dynamic>> recordSearch({
    required String userEmail,
    required String searchType,
    required String query,
  }) async {
    return _safePost(
      '$baseUrl/search_activity',
      {
        'user_email': userEmail,
        'search_type': searchType,
        'query': query,
      },
    );
  }

  static Future<Map<String, dynamic>> loadDashboardStats(String userEmail) async {
    final path = '/dashboard_stats?user_email=${Uri.encodeComponent(userEmail)}';
    return _safeGetWithFallback(Uri.parse('$baseUrl$path'), path);
  }

  static Future<Map<String, dynamic>> _safeGetWithFallback(Uri uri, String relativePath) async {
    var result = await _safeGet(uri);
    if (result['success'] == false) {
      final altBase = !isLocal ? localUrl : cloudUrl;
      try {
        final altUri = Uri.parse('$altBase$relativePath');
        final altResp = await http.get(altUri).timeout(const Duration(seconds: 8));
        final decoded = _decode(altResp);
        if (decoded['success'] == true) {
          _overrideBaseUrl = altBase;
          return decoded;
        }
      } catch (_) {}
    }
    return result;
  }

  static Future<Map<String, dynamic>> _safeGet(Uri uri, {Duration? timeout}) async {
    try {
      final response = await http.get(uri).timeout(timeout ?? requestTimeout);
      return _decode(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. The server or molecular computation may be busy.',
        'isTimeout': true,
      };
    } on SocketException {
      return {'success': false, 'message': 'Could not reach backend server at $baseUrl. Check your connection.'};
    } catch (e) {
      return {'success': false, 'message': 'Network request error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _safePost(String url, Map<String, dynamic> data, {Duration? timeout}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(timeout ?? requestTimeout);
      return _decode(response);
    } on TimeoutException {
      // If cloud timed out, try local
      if (!isLocal) {
        try {
          final localUrlStr = url.replaceFirst(cloudUrl, localUrl);
          final altResp = await http
              .post(
                Uri.parse(localUrlStr),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(data),
              )
              .timeout(const Duration(seconds: 10));
          final decoded = _decode(altResp);
          if (decoded['success'] == true) {
            _overrideBaseUrl = localUrl;
            return decoded;
          }
        } catch (_) {}
      }
      return {'success': false, 'message': 'Request timed out. Please check backend response.'};
    } on SocketException {
      return {'success': false, 'message': 'Could not reach backend server at $baseUrl.'};
    } catch (e) {
      return {'success': false, 'message': 'Network request error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _safeDelete(Uri uri, {Duration? timeout}) async {
    try {
      final response = await http.delete(uri).timeout(timeout ?? requestTimeout);
      return _decode(response);
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out.'};
    } on SocketException {
      return {'success': false, 'message': 'Could not reach backend server.'};
    } catch (e) {
      return {'success': false, 'message': 'Network request error: $e'};
    }
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return {'success': false, 'message': 'Server returned an empty response.'};
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Invalid server response structure.'};
      }
      if (response.statusCode >= 400) {
        return {
          'success': false,
          'message': (decoded['detail'] ?? decoded['message'] ?? 'Server request failed.').toString(),
        };
      }
      return decoded;
    } catch (_) {
      if (response.statusCode == 504) {
        return {
          'success': false,
          'message': 'Cloud server timed out (Render 504 Gateway Timeout). Please retry or switch to local server.',
          'isTimeout': true,
        };
      }
      return {'success': false, 'message': 'Failed to parse server response.'};
    }
  }
}
