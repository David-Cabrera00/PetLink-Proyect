import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AuthUser {
  final String name;
  final String email;

  const AuthUser({required this.name, required this.email});
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;

  const AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool clearUser = false,
    bool? isLoading,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._client) : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }
  final ApiClient _client;

  Future<void> _restoreSession() async {
    if (!_client.isConfigured || !await _client.hasToken()) {
      state = const AuthState();
      return;
    }
    try {
      final result = await _client.get('/auth/me') as Map;
      state = AuthState(
        user: AuthUser(
          name: result['name'] as String,
          email: result['email'] as String,
        ),
      );
    } catch (_) {
      await _client.clearToken();
      state = const AuthState();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_client.isConfigured) { await Future<void>.delayed(const Duration(milliseconds: 300)); state = AuthState(user: AuthUser(name: 'PetLink user', email: email.trim())); return; }
      final result = await _client.post('/auth/login', body: {'email': email.trim(), 'password': password});
      await _client.saveToken(result['accessToken'] as String);
      state = AuthState(user: AuthUser(name: result['user']['name'] as String, email: result['user']['email'] as String));
    } finally {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    state = const AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_client.isConfigured) { await Future<void>.delayed(const Duration(milliseconds: 300)); state = AuthState(user: AuthUser(name: name.trim(), email: email.trim())); return; }
      final result = await _client.post('/auth/register', body: {'name': name.trim(), 'email': email.trim(), 'password': password});
      await _client.saveToken(result['accessToken'] as String);
      state = AuthState(user: AuthUser(name: result['user']['name'] as String, email: result['user']['email'] as String));
    } finally {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _client.clearToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ApiClient.instance),
);
