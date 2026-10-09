import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String _overrideBaseUrl = '';

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
    _overrideBaseUrl = url;
  }

  static const Duration requestTimeout = Duration(seconds: 45);

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
    final uri = Uri.parse('$baseUrl/analyze').replace(queryParameters: {
      'protein': protein.trim(),
      'ligand': ligand.trim(),
      'user_email': userEmail.trim(),
    });
    return _safeGet(uri, timeout: const Duration(minutes: 5));
  }

  static Future<Map<String, dynamic>> searchProtein(String query) async {
    final uri = Uri.parse('$baseUrl/search_protein?query=${Uri.encodeComponent(query.trim())}');
    return _safeGet(uri);
  }

  static Future<Map<String, dynamic>> searchLigand(String query) async {
    final uri = Uri.parse('$baseUrl/search_ligand?query=${Uri.encodeComponent(query.trim())}');
    return _safeGet(uri);
  }

  static Future<Map<String, dynamic>> loadHistory(String userEmail) async {
    final uri = Uri.parse('$baseUrl/history').replace(queryParameters: {'user_email': userEmail});
    return _safeGet(uri);
  }

  static Future<Map<String, dynamic>> clearHistory(String userEmail) async {
    final uri = Uri.parse('$baseUrl/history').replace(queryParameters: {'user_email': userEmail});
    return _safeDelete(uri);
  }

  static Future<Map<String, dynamic>> loadSavedResults(String userEmail) async {
    final uri = Uri.parse('$baseUrl/saved_results').replace(queryParameters: {'user_email': userEmail});
    return _safeGet(uri);
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
    final uri = Uri.parse('$baseUrl/dashboard_stats').replace(queryParameters: {'user_email': userEmail});
    return _safeGet(uri);
  }

  static Future<Map<String, dynamic>> _safeGet(Uri uri, {Duration? timeout}) async {
    try {
      final response = await http.get(uri).timeout(timeout ?? requestTimeout);
      return _decode(response);
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out. The server or molecular computation may be busy.'};
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
      return {'success': false, 'message': 'Failed to parse server response.'};
    }
  }
}
