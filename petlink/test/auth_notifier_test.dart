import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petlink/core/network/api_client.dart';
import 'package:petlink/features/auth/providers/auth_provider.dart';

class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}

void main() {
  group('AuthNotifier - Restauración y Gestión de Sesión', () {
    const testBaseUrl = 'http://localhost:3000/api/v1';

    test('Sin token -> restaura estado no autenticado', () async {
      final storage = InMemorySessionStorage();
      final mockHttpClient = MockClient((request) async => http.Response('Not found', 404));

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);

      // Espera ciclo asíncrono de _restoreSession
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.sessionExpired, isFalse);

      notifier.dispose();
    });

    test('Con token -> /auth/me responde 200 -> sesión restaurada con usuario', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'valid_token');

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/me') {
          return http.Response(
            jsonEncode({
              'id': 'user-1',
              'name': 'Carlos Perez',
              'email': 'carlos@test.com',
              'avatarUrl': 'http://cdn/avatar.jpg',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.name, 'Carlos Perez');
      expect(notifier.state.user?.email, 'carlos@test.com');
      expect(notifier.state.user?.avatarUrl, 'http://cdn/avatar.jpg');

      // Verifica que se cacheó el usuario
      final cached = await client.readCachedUser();
      expect(cached?['name'], 'Carlos Perez');

      notifier.dispose();
    });

    test('Con token -> /auth/me devuelve 401 -> sesión expirada y limpia storage', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'revoked_token');
      await storage.write('petlink_refresh_token', 'revoked_refresh');

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/me') {
          return http.Response(
            jsonEncode({'statusCode': 401, 'message': 'Unauthorized'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response(
            jsonEncode({'statusCode': 401, 'message': 'Refresh token invalid'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.sessionExpired, isTrue);
      expect(await storage.read('petlink_access_token'), isNull);

      // Acknowledge session expired
      notifier.acknowledgeSessionExpired();
      expect(notifier.state.sessionExpired, isFalse);

      notifier.dispose();
    });

    test('Con token y perfil en caché -> error de red en /auth/me -> conserva perfil offline', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'offline_token');
      await storage.write(
        'petlink_user',
        jsonEncode({'name': 'Usuario Offline', 'email': 'offline@test.com'}),
      );

      final mockHttpClient = MockClient((request) async {
        throw http.ClientException('Sin conexión');
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.name, 'Usuario Offline');
      expect(notifier.state.sessionExpired, isFalse);
      // El token en storage se mantiene intacto
      expect(await storage.read('petlink_access_token'), 'offline_token');

      notifier.dispose();
    });

    test('login() exitoso guarda sesión y actualiza estado', () async {
      final storage = InMemorySessionStorage();

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return http.Response(
            jsonEncode({
              'accessToken': 'login_access_token',
              'refreshToken': 'login_refresh_token',
              'user': {'name': 'Ana', 'email': 'ana@test.com'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);
      await Future<void>.delayed(Duration.zero);

      await notifier.login(email: 'ana@test.com', password: 'password123');

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.name, 'Ana');
      expect(await storage.read('petlink_access_token'), 'login_access_token');
      expect(await storage.read('petlink_refresh_token'), 'login_refresh_token');

      notifier.dispose();
    });

    test('logout() limpia la sesión y restaura estado no autenticado', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'active_token');

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/logout') {
          return http.Response(jsonEncode({'status': 'ok'}), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not found', 404);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
      );

      final notifier = AuthNotifier(client);
      await Future<void>.delayed(Duration.zero);

      await notifier.logout();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(await storage.read('petlink_access_token'), isNull);

      notifier.dispose();
    });
  });
}
