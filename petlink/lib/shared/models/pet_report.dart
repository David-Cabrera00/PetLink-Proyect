import 'pet.dart';

enum ReportType { lost, found }

enum ReportStatus { active, possibleMatch, recovered, closed }

class PetReport {
  final String id;
  final Pet pet;
  final ReportType type;
  final ReportStatus status;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  final String description;
  final double distanceKm;
  final int sightingsCount;

  const PetReport({
    required this.id,
    required this.pet,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
    required this.lastSeenAt,
    required this.description,
    required this.distanceKm,
    required this.sightingsCount,
  });
}
