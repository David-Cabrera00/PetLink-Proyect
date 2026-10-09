import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  AuthNotifier() : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = AuthState(
      user: AuthUser(name: 'PetLink user', email: email.trim()),
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = const AuthState(
      user: AuthUser(name: 'Google User', email: 'google.user@petlink.demo'),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = AuthState(
      user: AuthUser(name: name.trim(), email: email.trim()),
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
