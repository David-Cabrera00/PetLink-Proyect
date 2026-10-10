import '../../models/pet.dart';
import '../../models/pet_report.dart';
import '../../models/report_draft.dart';
import '../pet_report_repository.dart';

class MockPetReportRepository implements PetReportRepository {
  final _createdReports = <PetReport>[];

  @override
  Future<List<PetReport>> getNearbyReports() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final reports = [
      PetReport(
        id: '1',
        pet: const Pet(
          id: 'p1',
          name: 'Luna',
          species: 'Perro',
          breed: 'Golden Retriever',
          sex: 'Hembra',
          age: '4 años',
          size: 'Grande',
          color: 'Dorado',
          description: 'Golden Retriever hembra de 4 años',
        ),
        type: ReportType.lost,
        status: ReportStatus.active,
        latitude: 1.2136,
        longitude: -77.2811,
        address: 'Barrio La Aurora, Pasto',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)),
        description: 'Perdida cerca del parque central',
        distanceKm: 0.8,
        sightingsCount: 3,
      ),
      PetReport(
        id: '2',
        pet: const Pet(
          id: 'p2',
          name: 'Toby',
          species: 'Perro',
          breed: 'Labrador',
          sex: 'Macho',
          age: '2 años',
          size: 'Mediano',
          color: 'Negro',
          description: 'Labrador macho de 2 años',
        ),
        type: ReportType.lost,
        status: ReportStatus.active,
        latitude: 1.2200,
        longitude: -77.2900,
        address: 'Barrio San Andrés, Pasto',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 6)),
        description: 'Se escapó del jardín',
        distanceKm: 1.2,
        sightingsCount: 1,
      ),
      PetReport(
        id: '3',
        pet: const Pet(
          id: 'p3',
          name: 'Golden',
          species: 'Perro',
          breed: 'Golden Retriever',
          sex: 'Hembra',
          age: 'Aprox. 3-4 años',
          size: 'Grande',
          color: 'Dorado',
          description: 'Golden Retriever encontrada',
        ),
        type: ReportType.found,
        status: ReportStatus.active,
        latitude: 1.2180,
        longitude: -77.2850,
        address: 'Parque Infantil, Pasto',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Encontrada cerca del parque infantil',
        distanceKm: 1.4,
        sightingsCount: 0,
      ),
      PetReport(
        id: '4',
        pet: const Pet(
          id: 'p4',
          name: 'Siamés',
          species: 'Gato',
          breed: 'Siamés',
          sex: 'Hembra',
          age: '1 año',
          size: 'Pequeño',
          color: 'Crema',
          description: 'Gata siamés encontrada',
        ),
        type: ReportType.found,
        status: ReportStatus.active,
        latitude: 1.2150,
        longitude: -77.2780,
        address: 'Barrio Centro, Pasto',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 1)),
        description: 'Gata siamés encontrada en la calle',
        distanceKm: 0.5,
        sightingsCount: 0,
      ),
    ];

    return [...reports, ..._createdReports];
  }

  @override
  Future<List<PetReport>> getMyReports() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      PetReport(
        id: '1',
        pet: const Pet(
          id: 'p1',
          name: 'Luna',
          species: 'Perro',
          breed: 'Golden Retriever',
          sex: 'Hembra',
          age: '4 años',
          size: 'Grande',
          color: 'Dorado',
          description: 'Golden Retriever hembra de 4 años',
        ),
        type: ReportType.lost,
        status: ReportStatus.active,
        latitude: 1.2136,
        longitude: -77.2811,
        address: 'Barrio La Aurora, Pasto',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)),
        description: 'Perdida cerca del parque central',
        distanceKm: 0.8,
        sightingsCount: 3,
      ),
      ..._createdReports,
    ];
  }

  @override
  Future<PetReport?> getReportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final reports = await getNearbyReports();
    try {
      return reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PetReport> createReport(ReportDraft draft) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final newReport = PetReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pet: Pet(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        name: draft.name,
        species: draft.species,
        breed: draft.breed,
        sex: draft.sex,
        age: draft.age,
        size: draft.size,
        color: draft.color,
        description: draft.description,
      ),
      type: draft.reportType!,
      status: ReportStatus.active,
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
      createdAt: DateTime.now(),
      lastSeenAt: draft.lastSeenAt ?? DateTime.now(),
      description: draft.description,
      distanceKm: 0.0,
      sightingsCount: 0,
    );

    _createdReports.add(newReport);
    return newReport;
  }
}
