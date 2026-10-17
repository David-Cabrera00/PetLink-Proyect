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

  factory PetReport.fromJson(Map<String, dynamic> json) => PetReport(
        id: json['id'] as String? ?? '', pet: Pet.fromJson((json['pet'] as Map?)?.cast<String, dynamic>() ?? json),
        type: (json['type'] as String? ?? 'lost').toLowerCase() == 'found' ? ReportType.found : ReportType.lost,
        status: ReportStatus.values.firstWhere((value) => value.name.toLowerCase() == (json['status'] as String? ?? 'active').toLowerCase(), orElse: () => ReportStatus.active),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0, longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        address: json['address'] as String? ?? '', createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        lastSeenAt: DateTime.tryParse(json['lastSeenAt'] as String? ?? '') ?? DateTime.now(), description: json['description'] as String? ?? '',
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0, sightingsCount: json['sightingsCount'] as int? ?? 0,
      );
}
