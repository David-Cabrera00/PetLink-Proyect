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

abstract class SessionStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSessionStorage implements SessionStorage {
  final FlutterSecureStorage _storage;
  const SecureSessionStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class ApiClient {
  ApiClient._({
    http.Client? httpClient,
    SessionStorage? storage,
    String? baseUrl,
    Duration? timeout,
    Duration? retryDelay,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = storage ?? const SecureSessionStorage(),
        _baseUrlOverride = baseUrl,
        timeout = timeout ?? const Duration(seconds: 30),
        retryDelay = retryDelay ?? const Duration(seconds: 2);

  static ApiClient instance = ApiClient._();

  factory ApiClient.forTesting({
    http.Client? httpClient,
    SessionStorage? storage,
    String? baseUrl,
    Duration? timeout,
    Duration? retryDelay,
  }) =>
      ApiClient._(
        httpClient: httpClient,
        storage: storage,
        baseUrl: baseUrl,
        timeout: timeout,
        retryDelay: retryDelay,
      );

  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://petlink-proyect-api.onrender.com/api/v1',
  );

  final http.Client _httpClient;
  final SessionStorage _storage;
  final String? _baseUrlOverride;
  final Duration timeout;
  final Duration retryDelay;

  String get baseUrl => _baseUrlOverride ?? defaultBaseUrl;

  static const _accessKey = 'petlink_access_token';
  static const _refreshKey = 'petlink_refresh_token';
  static const _userKey = 'petlink_user';

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
    await _storage.write(_accessKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(_refreshKey, refreshToken);
    }
    if (user != null) await saveCachedUser(user);
  }

  Future<void> saveCachedUser(Map<String, dynamic> user) =>
      _storage.write(_userKey, jsonEncode(user));

  Future<Map<String, dynamic>?> readCachedUser() async {
    final raw = await _storage.read(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(_accessKey);
    await _storage.delete(_refreshKey);
    await _storage.delete(_userKey);
  }

  Future<bool> hasToken() async =>
      (await _storage.read(_accessKey)) != null;

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

  Future<void> forgotPassword(String email) =>
      post('/auth/forgot-password', body: {'email': email}, skipAuthRefresh: true);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      post(
        '/auth/reset-password',
        body: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
        skipAuthRefresh: true,
      );

  Future<Map<String, dynamic>> analyzePetImage(String localPathOrUrl) async {
    if (localPathOrUrl.startsWith('http')) {
      final res = await post(
        '/ai/analyze-image',
        body: {'imageUrl': localPathOrUrl},
      );
      return (res as Map).cast<String, dynamic>();
    } else {
      final res = await uploadFile(localPathOrUrl, '/ai/analyze-image');
      return (res as Map).cast<String, dynamic>();
    }
  }

  Future<dynamic> uploadFile(String path, String endpoint) async {
    Future<http.StreamedResponse> send() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(await _authHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', path));
      return _httpClient.send(request);
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
        'GET' => _httpClient.get(uri, headers: headers),
        'POST' => _httpClient.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'DELETE' => _httpClient.delete(uri, headers: headers),
        _ => _httpClient.patch(uri, headers: headers, body: jsonEncode(body ?? {})),
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
    final token = await _storage.read(_accessKey);
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
        if (retryDelay > Duration.zero) {
          await Future<void>.delayed(retryDelay);
        }
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
    final refreshToken = await _storage.read(_refreshKey);
    if (refreshToken == null || refreshToken.isEmpty || !isConfigured) {
      await _expireSession();
      return false;
    }

    try {
      final response = await _httpClient
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
