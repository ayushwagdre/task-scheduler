import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../storage/token_store.dart';

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStore, this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokenStore;
  final Future<void> Function()? onUnauthorized;

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));
    assert(() {
      debugPrint('POST $uri -> ${resp.statusCode}');
      debugPrint(resp.body);
      return true;
    }());
    await _handleUnauthorized(resp);
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
    await _handleUnauthorized(resp);
    return _decodeEnvelope(resp);
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final resp = await http.delete(uri, headers: headers);
    assert(() {
      debugPrint('DELETE $uri -> ${resp.statusCode}');
      debugPrint(resp.body);
      return true;
    }());
    await _handleUnauthorized(resp);
    return _decodeEnvelope(resp);
  }

  Future<void> _handleUnauthorized(http.Response resp) async {
    if (resp.statusCode != 401) return;
    if (onUnauthorized != null) {
      await onUnauthorized!();
    } else {
      await tokenStore.clear();
    }
    throw ApiUnauthorizedException('Unauthorized');
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
      final data = obj['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List) return <String, dynamic>{'items': data};
      return <String, dynamic>{};
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

class ApiUnauthorizedException extends ApiException {
  ApiUnauthorizedException(super.message);
}

