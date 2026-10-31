import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petlink/core/network/api_client.dart';

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
  group('ApiClient - Sesión y Red', () {
    const testBaseUrl = 'http://localhost:3000/api/v1';

    test('401 inicial -> refresca token exitosamente -> reintenta con nuevo token', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'expired_access_token');
      await storage.write('petlink_refresh_token', 'valid_refresh_token');

      var reportsCallCount = 0;
      var refreshCallCount = 0;
      String? lastAuthHeader;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/reports') {
          reportsCallCount++;
          lastAuthHeader = request.headers['Authorization'];
          if (reportsCallCount == 1) {
            // Primer intento: token expirado
            return http.Response(
              jsonEncode({'statusCode': 401, 'message': 'Token expired'}),
              401,
              headers: {'content-type': 'application/json'},
            );
          } else {
            // Segundo intento tras refresh: exitoso
            return http.Response(
              jsonEncode([{'id': 'report-123', 'title': 'Perro encontrado'}]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
        }

        if (request.url.path == '/api/v1/auth/refresh') {
          refreshCallCount++;
          final body = jsonDecode(request.body) as Map;
          expect(body['refreshToken'], 'valid_refresh_token');
          return http.Response(
            jsonEncode({
              'accessToken': 'new_valid_access_token',
              'refreshToken': 'new_valid_refresh_token',
              'user': {'name': 'Juan', 'email': 'juan@test.com'},
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
        timeout: const Duration(milliseconds: 500),
      );

      final result = await client.get('/reports') as List;

      expect(reportsCallCount, 2);
      expect(refreshCallCount, 1);
      expect(lastAuthHeader, 'Bearer new_valid_access_token');
      expect(result.first['id'], 'report-123');

      // Verifica que el nuevo token se guardó en storage
      expect(await storage.read('petlink_access_token'), 'new_valid_access_token');
      expect(await storage.read('petlink_refresh_token'), 'new_valid_refresh_token');
    });

    test('401 inicial -> refresh token inválido (401) -> borra sesión y dispara onSessionExpired', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'bad_token');
      await storage.write('petlink_refresh_token', 'revoked_refresh_token');

      var expiredCalled = false;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/reports') {
          return http.Response(
            jsonEncode({'statusCode': 401, 'message': 'Unauthorized'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response(
            jsonEncode({'statusCode': 401, 'message': 'Invalid refresh token'}),
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
        timeout: const Duration(milliseconds: 500),
      );
      client.onSessionExpired = () {
        expiredCalled = true;
      };

      await expectLater(
        () => client.get('/reports'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );

      expect(expiredCalled, isTrue);
      expect(await storage.read('petlink_access_token'), isNull);
      expect(await storage.read('petlink_refresh_token'), isNull);
    });

    test('401 inicial -> error de red en refresh -> conserva sesión y NO dispara onSessionExpired', () async {
      final storage = InMemorySessionStorage();
      await storage.write('petlink_access_token', 'token');
      await storage.write('petlink_refresh_token', 'refresh_token');

      var expiredCalled = false;

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/reports') {
          return http.Response(
            jsonEncode({'statusCode': 401, 'message': 'Unauthorized'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          throw http.ClientException('Network down');
        }
        return http.Response('Not found', 404);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
        timeout: const Duration(milliseconds: 500),
      );
      client.onSessionExpired = () {
        expiredCalled = true;
      };

      await expectLater(
        () => client.get('/reports'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );

      expect(expiredCalled, isFalse);
      expect(await storage.read('petlink_refresh_token'), 'refresh_token');
    });

    test('Timeout en GET -> reintento automático tiene éxito', () async {
      final storage = InMemorySessionStorage();
      var attempt = 0;

      final mockHttpClient = MockClient((request) async {
        attempt++;
        if (attempt == 1) {
          // Simula que la primera petición excede el timeout
          await Future<void>.delayed(const Duration(milliseconds: 150));
          return http.Response('Late', 200);
        }
        return http.Response(
          jsonEncode({'status': 'ok'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
        timeout: const Duration(milliseconds: 50),
        retryDelay: Duration.zero,
      );

      final result = await client.get('/reports') as Map;
      expect(attempt, 2);
      expect(result['status'], 'ok');
    });

    test('Timeout en POST (sin reintento de red) -> lanza ApiException con kind timeout', () async {
      final storage = InMemorySessionStorage();

      final mockHttpClient = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        return http.Response('Late', 200);
      });

      final client = ApiClient.forTesting(
        httpClient: mockHttpClient,
        storage: storage,
        baseUrl: testBaseUrl,
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        () => client.post('/reports', body: {'title': 'Perro'}),
        throwsA(
          isA<ApiException>().having((e) => e.isTimeout, 'isTimeout', isTrue),
        ),
      );
    });

    test('Códigos HTTP 409, 429 y 500 lanzan ApiException tipada', () async {
      final storage = InMemorySessionStorage();

      for (final code in [409, 429, 500]) {
        final mockHttpClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'statusCode': code, 'message': 'Error $code'}),
            code,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ApiClient.forTesting(
          httpClient: mockHttpClient,
          storage: storage,
          baseUrl: testBaseUrl,
          timeout: const Duration(milliseconds: 200),
        );

        await expectLater(
          () => client.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', code)
                .having((e) => e.message, 'message', 'Error $code'),
          ),
        );
      }
    });
  });
}
