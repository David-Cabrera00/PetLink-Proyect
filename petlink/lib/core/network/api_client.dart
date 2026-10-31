import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

enum ApiErrorKind { http, network, timeout }

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final ApiErrorKind kind;

  const ApiException(
    this.statusCode,
    this.message, {
    this.kind = ApiErrorKind.http,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => kind == ApiErrorKind.network;
  bool get isTimeout => kind == ApiErrorKind.timeout;

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
  static const _accessKey = 'petlink_access_token';
  static const _refreshKey = 'petlink_refresh_token';
  static const _userKey = 'petlink_user';
  static const _storage = FlutterSecureStorage();

  /// Se dispara cuando la sesión ya no se puede recuperar (refresh inválido o
  /// inexistente). El AuthNotifier la usa para volver a la pantalla de acceso.
  void Function()? onSessionExpired;

  Future<bool>? _refreshInFlight;

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Sesión
  // ---------------------------------------------------------------------------

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
    if (user != null) await saveCachedUser(user);
  }

  Future<void> saveCachedUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> readCachedUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> hasToken() async =>
      (await _storage.read(key: _accessKey)) != null;

  // ---------------------------------------------------------------------------
  // HTTP
  // ---------------------------------------------------------------------------

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query, retryOnNetworkError: true);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool skipAuthRefresh = false,
  }) => _request('POST', path, body: body, skipAuthRefresh: skipAuthRefresh);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<dynamic> uploadFile(String path, String endpoint) async {
    Future<http.StreamedResponse> send() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(await _authHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', path));
      return request.send();
    }

    var response = await _performStreamed(send);

    if (response.statusCode == 401 && await _tryRefresh()) {
      response = await _performStreamed(send);
    }

    final rawBody = await response.stream.bytesToString();
    final decoded = _decode(rawBody);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded is Map && decoded['message'] != null
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
    bool retryOnNetworkError = false,
    bool skipAuthRefresh = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    Future<http.Response> send() async {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        ...await _authHeaders(),
      };
      return switch (method) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.patch(uri, headers: headers, body: jsonEncode(body ?? {})),
      };
    }

    var response = await _perform(
      send,
      retryOnNetworkError: retryOnNetworkError,
    );

    if (response.statusCode == 401 && !skipAuthRefresh) {
      if (await _tryRefresh()) {
        response = await _perform(send);
      }
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded is Map && decoded['message'] != null
            ? decoded['message'].toString()
            : 'Error de red',
      );
    }
    return decoded;
  }

  /// Evita que una respuesta no-JSON (por ejemplo, una página de error del
  /// hosting) rompa el flujo con un FormatException.
  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _accessKey);
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _perform(
    Future<http.Response> Function() send, {
    bool retryOnNetworkError = false,
  }) async {
    try {
      return await send().timeout(timeout);
    } on TimeoutException {
      if (retryOnNetworkError) {
        // Un reintento para cubrir arranques en frío del backend.
        await Future<void>.delayed(const Duration(seconds: 2));
        return _perform(send);
      }
      throw const ApiException(
        0,
        'La conexión tardó demasiado',
        kind: ApiErrorKind.timeout,
      );
    } on IOException {
      throw const ApiException(
        0,
        'Sin conexión a internet',
        kind: ApiErrorKind.network,
      );
    } on http.ClientException {
      throw const ApiException(
        0,
        'Sin conexión a internet',
        kind: ApiErrorKind.network,
      );
    }
  }

  Future<http.StreamedResponse> _performStreamed(
    Future<http.StreamedResponse> Function() send,
  ) async {
    try {
      return await send().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        0,
        'La conexión tardó demasiado',
        kind: ApiErrorKind.timeout,
      );
    } on IOException {
      throw const ApiException(
        0,
        'Sin conexión a internet',
        kind: ApiErrorKind.network,
      );
    } on http.ClientException {
      throw const ApiException(
        0,
        'Sin conexión a internet',
        kind: ApiErrorKind.network,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh token
  // ---------------------------------------------------------------------------

  /// Intenta renovar la sesión. Varias peticiones simultáneas comparten el
  /// mismo intento para no disparar refresh en paralelo.
  Future<bool> _tryRefresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _refreshSession();
    _refreshInFlight = future;
    return future.whenComplete(() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    });
  }

  Future<bool> _refreshSession() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    if (refreshToken == null || refreshToken.isEmpty || !isConfigured) {
      await _expireSession();
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is! Map) return false;
        final accessToken = data['accessToken'];
        if (accessToken is! String || accessToken.isEmpty) return false;

        await saveSession(
          accessToken: accessToken,
          refreshToken: data['refreshToken'] is String
              ? data['refreshToken'] as String
              : null,
          user: data['user'] is Map
              ? Map<String, dynamic>.from(data['user'] as Map)
              : null,
        );
        return true;
      }

      // El refresh token ya no es válido: cerramos la sesión.
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        await _expireSession();
      }
      return false;
    } on TimeoutException {
      // Sin conexión o backend dormido: conservamos la sesión y reintentamos
      // en la siguiente petición.
      return false;
    } on IOException {
      return false;
    } on http.ClientException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _expireSession() async {
    await clearSession();
    onSessionExpired?.call();
  }
}
