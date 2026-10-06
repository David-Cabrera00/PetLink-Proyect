import '../../models/pet.dart';
import '../../models/pet_report.dart';
import '../../models/pet_match.dart';
import '../match_repository.dart';

class MockMatchRepository implements MatchRepository {
  @override
  Future<List<PetMatch>> getMatchesForUser() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      PetMatch(
        id: 'm1',
        lostReport: PetReport(
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
        foundReport: PetReport(
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
        level: MatchLevel.high,
        distanceKm: 1.4,
        timeDifference: Duration(hours: 3),
        matchingTraits: const ['Raza', 'Color', 'Tamaño', 'Sexo'],
      ),
    ];
  }

  @override
  Future<PetMatch?> getMatchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final matches = await getMatchesForUser();
    try {
      return matches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
