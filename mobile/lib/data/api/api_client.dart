import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../storage/token_store.dart';

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStore});

  final String baseUrl;
  final TokenStore tokenStore;

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));
    assert(() {
      debugPrint('POST $uri -> ${resp.statusCode}');
      debugPrint(resp.body);
      return true;
    }());
    return _decodeEnvelope(resp);
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final resp = await http.get(uri, headers: headers);
    assert(() {
      debugPrint('GET $uri -> ${resp.statusCode}');
      debugPrint(resp.body);
      return true;
    }());
    return _decodeEnvelope(resp);
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenStore.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decodeEnvelope(http.Response resp) {
    final obj = jsonDecode(resp.body) as Map<String, dynamic>;
    if (obj['success'] == true) {
      return obj['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    }
    final err = (obj['error'] as Map<String, dynamic>?) ?? {};
    throw ApiException(err['description']?.toString() ?? 'Request failed');
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

