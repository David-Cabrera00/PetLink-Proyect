import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:petlink/features/explore/providers/explore_providers.dart';
import 'package:petlink/shared/models/pet.dart';
import 'package:petlink/shared/models/pet_report.dart';
import 'package:petlink/shared/models/report_draft.dart';
import 'package:petlink/shared/repositories/pet_report_repository.dart';
import 'package:petlink/features/radar/providers/radar_providers.dart';

void main() {
  final reports = [
    _report('near', ReportType.lost, 1.2136, -77.2811, 8),
    _report('far', ReportType.found, 1.3000, -77.2811, 1),
  ];

  test('filtra por tipo de reporte', () async {
    final container = _createContainer(reports);
    addTearDown(container.dispose);

    container.read(exploreFilterProvider.notifier).state = ExploreFilter.lost;

    final result = await container.read(exploreReportsProvider.future);

    expect(result.map((report) => report.id), ['near']);
  });

  test('filtra Cerca usando la ubicación GPS', () async {
    final container = _createContainer(reports);
    addTearDown(container.dispose);

    container.read(exploreLocationProvider.notifier).state =
        const LatLng(1.2136, -77.2811);
    container.read(exploreFilterProvider.notifier).state = ExploreFilter.nearby;

    final result = await container.read(exploreReportsProvider.future);

    expect(result.map((report) => report.id), ['near']);
  });
}

ProviderContainer _createContainer(List<PetReport> reports) {
  return ProviderContainer(
    overrides: [
      petReportRepositoryProvider.overrideWithValue(
        _FakePetReportRepository(reports),
      ),
    ],
  );
}

PetReport _report(
  String id,
  ReportType type,
  double latitude,
  double longitude,
  double distanceKm,
) {
  return PetReport(
    id: id,
    pet: const Pet(
      id: 'pet',
      name: 'Luna',
      species: 'Perro',
      breed: 'Mestizo',
      sex: 'Hembra',
      age: '3 años',
      size: 'Mediano',
      color: 'Dorado',
      description: 'Descripción',
    ),
    type: type,
    status: ReportStatus.active,
    latitude: latitude,
    longitude: longitude,
    address: 'Pasto',
    createdAt: DateTime(2026),
    lastSeenAt: DateTime(2026),
    description: 'Descripción',
    distanceKm: distanceKm,
    sightingsCount: 0,
  );
}

class _FakePetReportRepository implements PetReportRepository {
  _FakePetReportRepository(this.reports);

  final List<PetReport> reports;

  @override
  Future<List<PetReport>> getNearbyReports() async => reports;

  @override
  Future<List<PetReport>> getMyReports() async => reports;

  @override
  Future<PetReport?> getReportById(String id) async => null;

  @override
  Future<PetReport> createReport(ReportDraft draft) {
    throw UnimplementedError();
  }
}
