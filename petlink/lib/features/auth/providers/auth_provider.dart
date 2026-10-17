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

  const AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool clearUser = false, bool? isLoading}) => AuthState(
        user: clearUser ? null : user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._client) : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }

  final ApiClient _client;

  AuthUser _userFromJson(Map<dynamic, dynamic> json) => AuthUser(
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  Future<void> _restoreSession() async {
    if (!_client.isConfigured || !await _client.hasToken()) {
      state = const AuthState();
      return;
    }
    try {
      final result = await _client.get('/auth/me') as Map;
      state = AuthState(user: _userFromJson(result));
    } catch (_) {
      await _client.clearToken();
      state = const AuthState();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_client.isConfigured) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        state = AuthState(user: AuthUser(name: 'PetLink user', email: email.trim()));
        return;
      }
      final result = await _client.post('/auth/login', body: {'email': email.trim(), 'password': password.trim()});
      await _client.saveToken(result['accessToken'] as String);
      state = AuthState(user: _userFromJson(result['user'] as Map));
      await NotificationPermissionService.request();
    } finally {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    state = const AuthState();
  }

  Future<void> register({required String name, required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_client.isConfigured) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        state = AuthState(user: AuthUser(name: name.trim(), email: email.trim()));
        return;
      }
      final result = await _client.post('/auth/register', body: {'name': name.trim(), 'email': email.trim(), 'password': password.trim()});
      await _client.saveToken(result['accessToken'] as String);
      state = AuthState(user: _userFromJson(result['user'] as Map));
      await NotificationPermissionService.request();
    } finally {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateName(String name) async {
    final current = state.user;
    if (current == null) return;
    final result = await _client.patch('/auth/me', body: {'name': name.trim()}) as Map;
    state = AuthState(user: _userFromJson(result));
  }

  Future<void> uploadAvatar(String path) async {
    final current = state.user;
    if (current == null) return;
    final result = await _client.uploadFile(path, '/auth/me/avatar') as Map;
    state = AuthState(user: _userFromJson(result));
  }

  Future<void> logout() async {
    await _client.clearToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ApiClient.instance));
