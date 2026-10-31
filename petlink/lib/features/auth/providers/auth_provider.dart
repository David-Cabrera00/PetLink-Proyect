import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/notifications/notification_permission_service.dart';

class AuthUser {
  final String name;
  final String email;
  final String? avatarUrl;

  const AuthUser({required this.name, required this.email, this.avatarUrl});
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final bool sessionExpired;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.sessionExpired = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool clearUser = false,
    bool? isLoading,
    bool? sessionExpired,
  }) => AuthState(
    user: clearUser ? null : user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    sessionExpired: sessionExpired ?? this.sessionExpired,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._client) : super(const AuthState(isLoading: true)) {
    _client.onSessionExpired = _handleSessionExpired;
    _restoreSession();
  }

  final ApiClient _client;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _client.onSessionExpired = null;
    super.dispose();
  }

  AuthUser _userFromJson(Map<dynamic, dynamic> json) => AuthUser(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String?,
  );

  void _handleSessionExpired() {
    if (_disposed) return;
    state = const AuthState(sessionExpired: true);
  }

  void acknowledgeSessionExpired() {
    if (_disposed || !state.sessionExpired) return;
    state = state.copyWith(sessionExpired: false);
  }

  Future<void> _restoreSession() async {
    if (!_client.isConfigured || !await _client.hasToken()) {
      if (!_disposed) state = const AuthState();
      return;
    }

    // Mostramos el perfil cacheado de inmediato para no parpadear a Welcome
    // cuando el backend tarda (por ejemplo, arranque en frío).
    final cached = await _client.readCachedUser();
    if (cached != null && !_disposed) {
      state = AuthState(user: _userFromJson(cached));
    }

    try {
      final result = await _client.get('/auth/me') as Map;
      final user = _userFromJson(result);
      await _client.saveCachedUser(Map<String, dynamic>.from(result));
      if (!_disposed) state = AuthState(user: user);
    } on ApiException catch (error) {
      if (_disposed) return;
      if (error.isUnauthorized) {
        await _client.clearSession();
        if (!_disposed) state = const AuthState(sessionExpired: true);
      } else {
        // Error de red o servidor caído: conservamos la sesión cacheada.
        state = AuthState(user: cached == null ? null : _userFromJson(cached));
      }
    } catch (_) {
      if (!_disposed) {
        state = AuthState(user: cached == null ? null : _userFromJson(cached));
      }
    }
  }

  Future<void> _persistSession(Map<dynamic, dynamic> result) async {
    await _client.saveSession(
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] is String
          ? result['refreshToken'] as String
          : null,
      user: result['user'] is Map
          ? Map<String, dynamic>.from(result['user'] as Map)
          : null,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, sessionExpired: false);
    try {
      if (!_client.isConfigured) {
        if (kDebugMode) {
          // Modo desarrollo sin backend: sesión simulada.
          await Future<void>.delayed(const Duration(milliseconds: 300));
          state = AuthState(
            user: AuthUser(name: 'PetLink user', email: email.trim()),
          );
          return;
        }
        throw const ApiException(
          0,
          'API_BASE_URL no está configurada',
          kind: ApiErrorKind.network,
        );
      }
      final result = await _client.post(
        '/auth/login',
        body: {'email': email.trim(), 'password': password.trim()},
        skipAuthRefresh: true,
      ) as Map;
      await _persistSession(result);
      state = AuthState(user: _userFromJson(result['user'] as Map));
      await _requestNotificationPermission();
    } finally {
      if (!_disposed && state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, sessionExpired: false);
    try {
      if (!_client.isConfigured) {
        if (kDebugMode) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          state = AuthState(
            user: AuthUser(name: name.trim(), email: email.trim()),
          );
          return;
        }
        throw const ApiException(
          0,
          'API_BASE_URL no está configurada',
          kind: ApiErrorKind.network,
        );
      }
      final result = await _client.post(
        '/auth/register',
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
        },
        skipAuthRefresh: true,
      ) as Map;
      await _persistSession(result);
      state = AuthState(user: _userFromJson(result['user'] as Map));
      await _requestNotificationPermission();
    } finally {
      if (!_disposed && state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await NotificationPermissionService.request();
    } catch (_) {
      // El permiso es opcional: no debe romper el inicio de sesión.
    }
  }

  Future<void> updateName(String name) async {
    final current = state.user;
    if (current == null) return;
    final result =
        await _client.patch('/auth/me', body: {'name': name.trim()}) as Map;
    await _client.saveCachedUser(Map<String, dynamic>.from(result));
    if (!_disposed) state = AuthState(user: _userFromJson(result));
  }

  Future<void> uploadAvatar(String path) async {
    final current = state.user;
    if (current == null) return;
    final result = await _client.uploadFile(path, '/auth/me/avatar') as Map;
    await _client.saveCachedUser(Map<String, dynamic>.from(result));
    if (!_disposed) state = AuthState(user: _userFromJson(result));
  }

  Future<void> logout() async {
    await _client.clearSession();
    if (!_disposed) state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ApiClient.instance),
);

/// Email del usuario autenticado.
///
/// Las cachés de datos lo observan para descartarse cuando cambia la cuenta y
/// para no consultar la API cuando no hay sesión (por ejemplo, al cerrar
/// sesión).
final currentUserEmailProvider = Provider<String?>(
  (ref) => ref.watch(authProvider.select((state) => state.user?.email)),
);
