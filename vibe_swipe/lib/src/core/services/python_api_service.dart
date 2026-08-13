import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibe_swipe/src/core/services/registry_service/di.dart';
import 'package:vibe_swipe/src/core/services/remote_config_service.dart';

class PythonApiService {
  static String get baseUrl {
    try {
      return locator<RemoteConfigService>().pythonApiUrl;
    } catch (_) {
      return 'http://177.7.33.210:8000';
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> get _headers async {
    final user = _auth.currentUser;
    String? token;
    if (user != null) {
      token = await user.getIdToken();
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http
        .get(uri, headers: await _headers)
        .timeout(const Duration(seconds: 5));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 5));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 5));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl$path'),
          headers: await _headers,
        )
        .timeout(const Duration(seconds: 5));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: body['detail'] ?? 'Unknown error',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
