import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const timeout = Duration(seconds: 30);
  static const _tokenKey = 'petlink_access_token';
  static const _storage = FlutterSecureStorage();

  bool get isConfigured => baseUrl.trim().isNotEmpty;
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
  Future<bool> hasToken() async =>
      (await _storage.read(key: _tokenKey)) != null;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _request('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<dynamic> uploadFile(String path, String endpoint) async {
    final token = await _storage.read(key: _tokenKey);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.files.add(await http.MultipartFile.fromPath('file', path));
    final response = await request.send().timeout(timeout);
    final body = await response.stream.bytesToString();
    final decoded = body.isEmpty ? null : jsonDecode(body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded is Map
            ? decoded['message'].toString()
            : 'Error al subir la foto',
      );
    }
    return decoded;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final token = await _storage.read(key: _tokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = switch (method) {
      'GET' => await http.get(uri, headers: headers).timeout(timeout),
      'POST' =>
        await http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(timeout),
      'DELETE' => await http.delete(uri, headers: headers).timeout(timeout),
      _ =>
        await http
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(timeout),
    };
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Error de red';
      throw ApiException(response.statusCode, message);
    }
    return decoded;
  }
}
