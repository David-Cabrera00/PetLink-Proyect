import 'package:flutter_test/flutter_test.dart';
import 'package:petlink/core/network/api_client.dart';
import 'package:petlink/shared/models/pet_report.dart';
import 'package:petlink/shared/models/report_draft.dart';
import 'package:petlink/shared/repositories/pet_report_repository.dart';
import 'package:petlink/shared/repositories/remote/remote_pet_report_repository.dart';

class _FakeApiClient implements ApiClient {
  int postCallCount = 0;
  int uploadCallCount = 0;
  bool failOnSecondPhoto = false;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool skipAuthRefresh = false,
  }) async {
    postCallCount++;
    if (path == '/reports') {
      return {
        'id': 'report-123',
        'type': body?['type'] ?? 'LOST',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'userId': 'user-1',
        'latitude': body?['latitude'] ?? 1.2136,
        'longitude': body?['longitude'] ?? -77.2811,
        'address': body?['address'] ?? 'Calle 10, Pasto',
        'pet': {
          'id': 'pet-123',
          'name': body?['name'] ?? 'Firulais',
          'species': body?['species'] ?? 'Perro',
          'photos': <String>[],
        },
      };
    }
    return {};
  }

  @override
  Future<dynamic> uploadFile(String path, String endpoint) async {
    uploadCallCount++;
    if (failOnSecondPhoto && uploadCallCount == 2) {
      throw const ApiException(
        0,
        'Simulated network disconnection on photo 2',
        kind: ApiErrorKind.network,
      );
    }
    return {'url': 'https://cdn.petlink.app/$path'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RemotePetReportRepository - Prevención de duplicados', () {
    test('sube reporte y todas las fotos exitosamente', () async {
      final fakeClient = _FakeApiClient();
      final repository = RemotePetReportRepository(fakeClient);

      final draft = ReportDraft(
        name: 'Firulais',
        species: 'Perro',
        photos: ['path/photo1.jpg', 'path/photo2.jpg', 'path/photo3.jpg'],
        reportType: ReportType.lost,
        latitude: 1.2136,
        longitude: -77.2811,
      );

      final report = await repository.createReport(draft);

      expect(report.id, 'report-123');
      expect(fakeClient.postCallCount, 1);
      expect(fakeClient.uploadCallCount, 3);
    });

    test(
        'lanza PartialReportUploadException con reporte creado si se corta la red en la segunda foto',
        () async {
      final fakeClient = _FakeApiClient()..failOnSecondPhoto = true;
      final repository = RemotePetReportRepository(fakeClient);

      final draft = ReportDraft(
        name: 'Firulais',
        species: 'Perro',
        photos: ['path/photo1.jpg', 'path/photo2.jpg', 'path/photo3.jpg'],
        reportType: ReportType.lost,
        latitude: 1.2136,
        longitude: -77.2811,
      );

      await expectLater(
        repository.createReport(draft),
        throwsA(
          isA<PartialReportUploadException>()
              .having((e) => e.report.id, 'report.id', 'report-123')
              .having((e) => e.failedPhotosCount, 'failedPhotosCount', 1)
              .having((e) => e.totalPhotosCount, 'totalPhotosCount', 3)
              .having((e) => e.cause, 'cause', isA<ApiException>()),
        ),
      );

      // El reporte solo se envió 1 vez (sin duplicación en backend)
      expect(fakeClient.postCallCount, 1);
      // Se intentaron subir las fotos
      expect(fakeClient.uploadCallCount, 3);
    });
  });
}
